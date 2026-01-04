## PostgreSQL Connection Monitoring Feature
## Targets: pg/conn/list, pg/conn/count, pg/conn/long-running
ifndef __MB_PG_FEATURE_CONN__
__MB_PG_FEATURE_CONN__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/conn/list: ## List all active connections with details
	$(call mb_printf_info,Listing active connections)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT pid$(mb_comma) usename$(mb_comma) datname$(mb_comma) client_addr$(mb_comma) state$(mb_comma) query_start$(mb_comma) left(query$(mb_comma) 50) as query \
	FROM pg_stat_activity WHERE pid <> pg_backend_pid() ORDER BY query_start;")

pg/conn/count: ## Count connections by state
	$(call mb_printf_info,Connection count by state)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT state$(mb_comma) count(*) FROM pg_stat_activity GROUP BY state ORDER BY count DESC;")

pg/conn/long-running: ## Find queries running longer than pg_long_query_threshold seconds (default: 60)
	$(call mb_printf_info,Queries running longer than $(pg_long_query_threshold) seconds)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT pid$(mb_comma) usename$(mb_comma) datname$(mb_comma) now() - query_start AS duration$(mb_comma) state$(mb_comma) left(query$(mb_comma) 80) as query \
	FROM pg_stat_activity \
	WHERE state = 'active' AND query_start < now() - interval '$(pg_long_query_threshold) seconds' \
	AND pid <> pg_backend_pid() \
	ORDER BY query_start;")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_CONN__
