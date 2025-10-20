ifndef __MB_MODULES_PHP_SYMFONY_SUBMODULE_DOCTRINE__
__MB_MODULES_PHP_SYMFONY_SUBMODULE_DOCTRINE__ := 1

.PHONY: php/sy/logs/tail/all php/sy/doctrine/db/create php/sy/doctrine/db/drop php/sy/doctrine/db/migrate


# -------------------- Database --------------------

php/sy/doctrine/db/create: mb_info_msg := Creating database (if not exists)
php/sy/doctrine/db/create: mb/info-$$@
php/sy/doctrine/db/create: ## Create database (idempotent)
	$(call php_sy_bin_console,doctrine:database:create --if-not-exists $(php_sy_conn_flag) $(php_sy_console_env_flag))

php/sy/doctrine/db/drop: mb_info_msg := Dropping database if exists
php/sy/doctrine/db/drop: mb/info-$$@
php/sy/doctrine/db/drop: ## Drop database (idempotent) [requires confirmation]
	$(if $(call mb_user_confirm,Drop database $(if $(php_sy_conn),for) connection '$(php_sy_conn)'?) ,\
		$(call php_sy_bin_console,doctrine:database:drop --if-exists --force $(php_sy_conn_flag) $(php_sy_console_env_flag))
	,\
		$(call mb_printf_warn, Aborted by user) \
	)

php/sy/doctrine/db/reset: php/sy/doctrine/db/drop .WAIT php/sy/doctrine/db/create
php/sy/doctrine/db/reset: ## Drop + Create database (idempotent) [requires confirmation for drop]

# -------------------- Schema (SchemaTool) --------------------
php/sy/doctrine/schema/validate: ## Validate mapping vs DB
	$(call php_sy_bin_console,doctrine:schema:validate $(php_sy_console_env_flag))

php/sy/doctrine/schema/create: ## Create tables from mapping (no migrations)
	$(call mb_printf_warn, Using SchemaTool CREATE (dev-only). Prefer migrations in team/CI.)
	$(call php_sy_bin_console,doctrine:schema:create $(php_sy_console_env_flag))

php/sy/doctrine/schema/update: ## Update schema to match mapping (no migrations)
	$(call mb_printf_warn, Using SchemaTool UPDATE (dev-only). Prefer migrations in team/CI.)
	$(call php_sy_bin_console,doctrine:schema:update $(php_sy_schema_update_flags) --force $(php_sy_console_env_flag))

# -------------------- Migrations --------------------
php/sy/doctrine/mig/diff: ## Generate migration from mapping changes
	$(call php_sy_bin_console,doctrine:migrations:diff $(php_sy_console_env_flag))

php/sy/doctrine/mig/migrate: ## Run pending migrations
	$(call php_sy_bin_console,doctrine:migrations:migrate $(php_sy_doctrine_migrate_flags) $(php_sy_console_env_flag))

php/sy/doctrine/mig/status: ## Show migrations status
	$(call php_sy_bin_console,doctrine:migrations:status $(php_sy_console_env_flag))

php/sy/doctrine/mig/list: ## List all migrations
	$(call php_sy_bin_console,doctrine:migrations:list $(php_sy_console_env_flag))

php/sy/doctrine/mig/dump: ## Dump current DB schema into a migration (baseline)
	$(call php_sy_bin_console,doctrine:migrations:dump-schema $(php_sy_console_env_flag))

# -------------------- Fixtures --------------------
php/sy/doctrine/fixtures/load: ## Load fixtures (purges DB unless --append)
	$(call mb_printf_info, Loading fixtures $(if $(findstring --append,$(php_sy_fixtures_flags)),(append), (purge)) )
	$(call php_sy_bin_console,doctrine:fixtures:load $(php_sy_fixtures_flags) $(php_sy_doctrine_migrate_flags) $(php_sy_console_env_flag))

# -------------------- Common flows --------------------
php/sy/doctrine/dev/rebuild: php/sy/doctrine/db/reset
php/sy/doctrine/dev/rebuild: php/sy/doctrine/mig/migrate
php/sy/doctrine/dev/rebuild: php/sy/doctrine/fixtures/load
php/sy/doctrine/dev/rebuild: ## Reset DB, migrate, load fixtures (dev seed)

php/sy/doctrine/test/reset: php_sy_env := test
php/sy/doctrine/test/reset: php/sy/doctrine/db/reset
php/sy/doctrine/test/reset: php/sy/doctrine/mig/migrate
php/sy/doctrine/test/reset: ## Fresh test DB (drop/create/migrate) – no fixtures by default



endif # __MB_MODULES_PHP_SYMFONY_SUBMODULE_DOCTRINE__