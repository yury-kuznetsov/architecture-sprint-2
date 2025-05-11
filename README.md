# pymongo-api
Инструкция по запуску сервиса

## Установка

```shell
docker compose up -d
```

Фактически запустится четыре сервера MongoDB в различных режимах — роутера, шардов, сервера конфигурации. 
Запрос попадает сначала на роутер, где будет определён шард, на котором хранится информация.

Чтобы всё полноценно заработало, нужно выполнить ещё ряд команд после запуска.

Подключитесь к серверу конфигурации и сделайте инициализацию:

```shell
docker exec -it configSrv mongosh --port 27017

> rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
> exit(); 
```

Инициализируйте шарды:

```shell
docker exec -it shard1-1 mongosh --port 27019

> rs.initiate({
  _id : "shard1",
  members: [
    { _id : 0, host : "shard1-1:27019" },
    { _id : 1, host : "shard1-2:27019" },
    { _id : 2, host : "shard1-3:27019" },
  ]
});
> exit();

docker exec -it shard2-1 mongosh --port 27020

> rs.initiate({
  _id : "shard2",
  members: [
    { _id : 0, host : "shard2-1:27020" },
    { _id : 1, host : "shard2-2:27020" },
    { _id : 2, host : "shard2-3:27020" },
  ]
});
> exit(); 
```

Инцициализируйте роутер и наполните его тестовыми данными:

```shell
docker exec -it mongos_router mongosh --port 27018

> sh.addShard( "shard1/shard1-1:27019,shard1-2:27019,shard1-3:27019");
> sh.addShard( "shard2/shard2-1:27020,shard2-2:27020,shard2-3:27020");

> sh.enableSharding("somedb");
> sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

> use somedb

> for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

> db.helloDoc.countDocuments() 
> exit();
```