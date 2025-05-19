#!/bin/bash
set -e

init() {
  local host=$1
  local config=$2

  until mongosh --host "$host" --eval "db.adminCommand('ping')" &> /dev/null
  do
    echo "⏳️ $host: waiting..."
    sleep 2
  done

  mongosh --host "$host" --eval "$config"
  echo "✅ $host: done"
}

init mongo-config:27017 '
  rs.initiate({
    _id : "config_server",
    configsvr: true,
    members: [
      { _id: 0, host: "mongo-config:27017" }
    ]
  });
'

init mongo-shard-1-1:27019 '
  try {
    rs.initiate({
      _id : "shard1",
      members: [
        { _id: 0, host: "mongo-shard-1-1:27019" },
        { _id: 1, host: "mongo-shard-1-2:27019" },
        { _id: 2, host: "mongo-shard-1-3:27019" }
      ]
    });
  } catch (e) {
    if (e.codeName !== "AlreadyInitialized" && (!e.code || e.code !== 23)) {
      print("❌ Ошибка инициализации shard1: " + e);
      quit(1);
    }
  }
'

init mongo-shard-2-1:27020 '
  try {
    rs.initiate({
      _id : "shard2",
      members: [
        { _id: 0, host: "mongo-shard-2-1:27020" },
        { _id: 1, host: "mongo-shard-2-2:27020" },
        { _id: 2, host: "mongo-shard-2-3:27020" }
      ]
    });
  } catch (e) {
    if (e.codeName !== "AlreadyInitialized" && (!e.code || e.code !== 23)) {
      print("❌ Ошибка инициализации shard2: " + e);
      quit(1);
    }
  }
'

init mongo-router:27018 '
  sh.addShard("shard1/mongo-shard-1-1:27019,mongo-shard-1-2:27019,mongo-shard-1-3:27019");
  sh.addShard("shard2/mongo-shard-2-1:27020,mongo-shard-2-2:27020,mongo-shard-2-3:27020");

  sh.enableSharding("somedb");
  sh.shardCollection("somedb.helloDoc", { "name": "hashed" });

  use("somedb");
  for (var i = 0; i < 1000; i++) db.helloDoc.insert({ age: i, name: "ly" + i });
  db.helloDoc.countDocuments();
'
