## PostgreSQL Index Management Feature
## Targets: pg/index/list, pg/index/unused, pg/index/reindex, pg/index/reindex/%
ifndef __MB_PG_FEATURE_INDEX__
__MB_PG_FEATURE_INDEX__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/index/list: ## List indexes with size and usage stats
	$(call mb_printf_info,Listing indexes in '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT schemaname$(mb_comma) tablename$(mb_comma) indexname$(mb_comma) \
	pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as size$(mb_comma) \
	idx_scan as scans \
	FROM pg_stat_user_indexes \
	ORDER BY pg_relation_size(schemaname||'.'||indexname) DESC;")

pg/index/unused: ## List potentially unused indexes (0 scans)
	$(call mb_printf_info,Listing unused indexes in '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT schemaname$(mb_comma) tablename$(mb_comma) indexname$(mb_comma) \
	pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as size \
	FROM pg_stat_user_indexes \
	WHERE idx_scan = 0 \
	ORDER BY pg_relation_size(schemaname||'.'||indexname) DESC;")

pg/index/reindex: ## Reindex the database (rebuilds all indexes)
	$(call mb_printf_info,Reindexing database '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "REINDEX DATABASE \"$(pg_db)\";")

pg/index/reindex/%: ## Reindex specific table (make pg/index/reindex/users)
	$(call mb_printf_info,Reindexing table: $*)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "REINDEX TABLE $*;")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_INDEX__
