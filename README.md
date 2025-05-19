# pymongo-api
Инструкция по запуску сервиса

## Установка

```shell
make up
```

## Mongo DB

В процессе установки запустится контейнер `mongo-init`, который сам все настроит:
```shell
docker compose logs -f mongo-init
```

Проверить работу:
```shell
make check check-1 check-2
```

## API Gateway

Вызвать Consul для регистрации сервисов:

```shell
curl "http://127.0.0.1:8500/v1/agent/service/register" -X PUT \
  -H "Content-Type: application/json" \
  -d '{
    "ID": "web-1",
    "Name": "web",
    "Address": "173.17.0.18",
    "Port": 8080,
    "Weights": {
      "Passing": 10,
      "Warning": 1
    }
  }'

curl "http://127.0.0.1:8500/v1/agent/service/register" -X PUT \
  -H "Content-Type: application/json" \
  -d '{
    "ID": "web-2",
    "Name": "web",
    "Address": "173.17.0.19",
    "Port": 8080,
    "Weights": {
      "Passing": 10,
      "Warning": 1
    }
  }'
```

Проверить регистрацию можно через [веб-панель](http://localhost:8500/) или через консоль:
```shell
curl http://127.0.0.1:8500/v1/catalog/service/web | jq
```

Зарегистрируйте маршрут через consul:
```shell
curl  -X PUT http://127.0.0.1:9180/apisix/admin/routes \
  -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
  -d '{
    "id": "consul-web-route",
    "uri": "*",
    "upstream": {
      "service_name": "web",
      "discovery_type": "consul",
      "type": "roundrobin"
    }
  }' | jq
```

Проверить результат можно через [веб](http://127.0.0.1:9080/docs/) или через консоль:
```shell
curl "http://127.0.0.1:9080/docs" 
```

[Ссылка на схему](https://www.dropbox.com/scl/fi/joodumbv736jcyc6ed369/sprint-2.drawio?rlkey=9kcq2aclnx10azdbab65onf62&st=07oanh1c&dl=0)