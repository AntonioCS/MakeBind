## PostgreSQL SQL Execution Feature
## Targets: pg/sql/file/%, pg/sql/exec, pg/query
ifndef __MB_PG_FEATURE_SQL__
__MB_PG_FEATURE_SQL__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/sql/file/%: ## Execute a .sql file (make pg/sql/file/path/to/script.sql)
	$(call mb_printf_info,Executing SQL file: $*)
	$(if $(wildcard $*),,$(call mb_printf_error,SQL file not found: $*); exit 2)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -f "$*")

pg/sql/exec: ## Execute SQL query (pg_query="SELECT ...")
	$(call mb_printf_info,Executing SQL query)
	$(if $(value pg_query),,$(error Please provide pg_query="<SQL query>"))
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c "$(pg_query)")

pg/query: pg/sql/exec ## Alias for pg/sql/exec

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_SQL__
