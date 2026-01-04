## PostgreSQL Core Feature
## Targets: pg/ping, pg/whoami, pg/info, pg/version, pg/psql
ifndef __MB_PG_FEATURE_CORE__
__MB_PG_FEATURE_CORE__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/ping: ## Quick SELECT 1 to verify connectivity
	$(call mb_printf_info,Checking PostgreSQL connectivity to '$(pg_db)' as '$(pg_user)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "SELECT 1;")

pg/whoami: ## Show current_user and database
	$(call mb_printf_info,Current database and user)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "SELECT current_database()$(mb_comma) current_user;")

pg/info: ## Server version + list databases
	$(call mb_printf_info,Server version and databases)
	$(call pg_invoke,$(pg_psql) -Atc "SHOW server_version;")
	$(call pg_invoke,$(pg_psql) -l)

pg/version: ## Show PostgreSQL server version
	$(call mb_printf_info,PostgreSQL server version)
	$(call pg_invoke,$(pg_psql) -Atc "SELECT version();")

pg/psql: ## Interactive psql session
	$(call mb_printf_info,Opening interactive psql to '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db))

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_CORE__
