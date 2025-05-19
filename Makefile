SHELL=/bin/bash
DC=docker compose

.DEFAULT_GOAL := help

up: ## Run containers
	$(DC) up -d

down: ## Stop containers
	$(DC) down -v

check: ## Check count of documents
	$(DC) exec -T mongo-router mongosh --port 27018 --quiet --eval 'use("somedb"); db.helloDoc.countDocuments();'

check-1: ## Check count of documents on shard-1
	$(DC) exec -T mongo-shard-1-1 mongosh --port 27019 --quiet --eval 'use("somedb"); db.helloDoc.countDocuments();'

check-2: ## Check count of documents on shard-1
	$(DC) exec -T mongo-shard-2-1 mongosh --port 27020 --quiet --eval 'use("somedb"); db.helloDoc.countDocuments();'

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'