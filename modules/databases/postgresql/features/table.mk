## PostgreSQL Table & Schema Introspection Feature
## Targets: pg/schema/list, pg/table/list, pg/table/count/%, pg/table/describe/%, pg/table/stats
ifndef __MB_PG_FEATURE_TABLE__
__MB_PG_FEATURE_TABLE__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/schema/list: ## List schemas and owners
	$(call mb_printf_info,Listing schemas and owners)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT nspname AS schema$(mb_comma) pg_catalog.pg_get_userbyid(nspowner) AS owner \
	FROM pg_namespace WHERE nspname NOT LIKE 'pg_%' ORDER BY 1;")

pg/table/list: ## List all tables with size
	$(call mb_printf_info,Listing all tables in '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT schemaname$(mb_comma) tablename$(mb_comma) pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size \
	FROM pg_tables WHERE schemaname NOT IN ('pg_catalog'$(mb_comma) 'information_schema') \
	ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;")

pg/table/count/%: ## Count rows in table (make pg/table/count/users or pg/table/count/public.users)
	$(call mb_printf_info,Counting rows in: $*)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "SELECT COUNT(*) FROM $*;")

pg/table/describe/%: ## Describe table structure
	$(call mb_printf_info,Describing table: $*)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c "\d+ $*")

pg/table/stats: ## Show table statistics (row counts, dead tuples)
	$(call mb_printf_info,Table statistics for '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT schemaname$(mb_comma) relname$(mb_comma) n_live_tup$(mb_comma) n_dead_tup$(mb_comma) last_vacuum$(mb_comma) last_autovacuum \
	FROM pg_stat_user_tables ORDER BY n_dead_tup DESC LIMIT 20;")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_TABLE__
