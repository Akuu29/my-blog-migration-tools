.PHONY: run-local-container run-local-container migrate-% revert-% info-% connect_db-%

run-local-container:
	docker network create my-blog-network || true
	docker compose build
	docker compose up

run-container-bash:
	docker compose exec database bash

migrate-%:
	@$(if $(filter $*, dev stg prd),,$(error Invalid STAGE $*))
	@source .env.$* && sqlx migrate run --database-url $${DATABASE_URL}

revert-%:
	@$(if $(filter $*, dev stg prd),,$(error Invalid STAGE $*))
	@source .env.$* && sqlx migrate revert --database-url $${DATABASE_URL}

# List all available migrations
info-%:
	@$(if $(filter $*, dev stg prd),,$(error Invalid STAGE $*))
	@source .env.$* && sqlx migrate info --source ./migrations --database-url $${DATABASE_URL}

connect-db-%:
	@$(if $(filter $*, dev stg prd),,$(error Invalid STAGE $*))
	@source .env.$* && psql $${DATABASE_URL}

# Insert seed data
insert-seed-%:
	@$(if $(filter $*, dev stg prd),,$(error Invalid STAGE $*))
	cargo run --bin seed -- --env $*
