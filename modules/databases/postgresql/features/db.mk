## PostgreSQL Database Management Feature
## Targets: pg/db/create/%, pg/db/drop/%, pg/db/reset/%, pg/db/exists/%, pg/db/list, pg/size
ifndef __MB_PG_FEATURE_DB__
__MB_PG_FEATURE_DB__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/db/create/%: ## Create database <name> (idempotent)
	$(call mb_printf_info,Creating database: $*)
	$(call pg_invoke,$(pg_psql) -d postgres -Atc \
	"DO \$$\$$ BEGIN IF NOT EXISTS (SELECT FROM pg_database WHERE datname='$*') THEN CREATE DATABASE \"$*\"; END IF; END \$$\$$;")

pg/db/drop/%: ## Drop database <name> (terminates sessions first)
	$(call mb_printf_info,Dropping database: $*)
	$(call pg_invoke,$(pg_psql) -d postgres -Atc \
	"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$*' AND pid <> pg_backend_pid();")
	$(call pg_invoke,$(pg_psql) -d postgres -Atc "DROP DATABASE IF EXISTS \"$*\";")

pg/db/reset/%: pg/db/drop/% ## Drop then create database <name>
	$(call pg_invoke,$(pg_psql) -d postgres -Atc "CREATE DATABASE \"$*\";")

pg/db/exists/%: ## Check if database <name> exists
	$(call mb_printf_info,Checking if database exists: $*)
	@$(pg_env_pass) $(pg_psql) -d postgres -Atc "SELECT 1 FROM pg_database WHERE datname='$*';" | grep -q 1 && \
		echo "Database '$*' exists" || \
		echo "Database '$*' does NOT exist"

pg/db/list: ## List all databases with size
	$(call mb_printf_info,Listing all databases)
	$(call pg_invoke,$(pg_psql) -d postgres -c \
	"SELECT datname$(mb_comma) pg_size_pretty(pg_database_size(datname)) as size FROM pg_database ORDER BY pg_database_size(datname) DESC;")

pg/size: ## Show size of current database
	$(call mb_printf_info,Database size for '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc \
	"SELECT pg_size_pretty(pg_database_size(current_database()));")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_DB__
