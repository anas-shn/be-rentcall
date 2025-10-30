.PHONY: help build up down restart logs shell db-shell db-migrate db-push db-studio clean

help: ## Tampilkan bantuan
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker-compose build

up: ## Start semua services
	docker-compose up -d

down: ## Stop semua services
	docker-compose down

restart: ## Restart semua services
	docker-compose restart

logs: ## Tampilkan logs
	docker-compose logs -f

logs-app: ## Tampilkan logs aplikasi saja
	docker-compose logs -f app

logs-db: ## Tampilkan logs database saja
	docker-compose logs -f postgres

shell: ## Masuk ke container aplikasi
	docker-compose exec app sh

db-shell: ## Masuk ke PostgreSQL shell
	docker-compose exec postgres psql -U admin_rentcall -d db_rentcall

db-migrate: ## Jalankan Prisma migrations
	docker-compose exec app bunx prisma migrate deploy

db-push: ## Push schema ke database
	docker-compose exec app bunx prisma db push

db-studio: ## Buka Prisma Studio
	docker-compose exec app bunx prisma studio

db-backup: ## Backup database
	docker-compose exec -T postgres pg_dump -U admin_rentcall db_rentcall > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup created: backup_$(shell date +%Y%m%d_%H%M%S).sql"

clean: ## Stop dan hapus containers + volumes
	docker-compose down -v

rebuild: ## Rebuild dan restart
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

status: ## Tampilkan status containers
	docker-compose ps

dev: ## Start dalam mode development
	docker-compose up

prod: ## Start dalam mode production
	docker-compose up -d --build
