# pymongo-api
Инструкция по запуску сервиса

## Установка

```shell
make up
```

В процессе установки запустится контейнер `mongo-init`, который сам все настроит:
```shell
docker compose logs -f mongo-init
```

Проверить работу:
```shell
make check check-1 check-2
```