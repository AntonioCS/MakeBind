## PostgreSQL Maintenance Feature
## Targets: pg/vacuum/analyze, pg/vacuum/full, pg/vacuum/%, pg/analyze, pg/bloat
ifndef __MB_PG_FEATURE_MAINTENANCE__
__MB_PG_FEATURE_MAINTENANCE__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/vacuum/analyze: ## VACUUM ANALYZE current database
	$(call mb_printf_info,Running VACUUM ANALYZE on '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "VACUUM (ANALYZE);")

pg/vacuum/full: ## VACUUM FULL ANALYZE (requires exclusive lock, reclaims space)
	$(call mb_printf_info,Running VACUUM FULL ANALYZE on '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "VACUUM (FULL$(mb_comma) ANALYZE);")

pg/vacuum/%: ## VACUUM ANALYZE specific table
	$(call mb_printf_info,Running VACUUM ANALYZE on table: $*)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "VACUUM (ANALYZE) $*;")

pg/analyze: ## ANALYZE only (update statistics, no vacuum)
	$(call mb_printf_info,Running ANALYZE on '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "ANALYZE;")

pg/bloat: ## Show table and index bloat estimates
	$(call mb_printf_info,Checking bloat in '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT schemaname$(mb_comma) tablename$(mb_comma) \
	pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size$(mb_comma) \
	n_dead_tup as dead_tuples$(mb_comma) \
	CASE WHEN n_live_tup > 0 THEN round(100.0 * n_dead_tup / n_live_tup$(mb_comma) 2) ELSE 0 END as dead_pct \
	FROM pg_stat_user_tables \
	WHERE n_dead_tup > 1000 \
	ORDER BY n_dead_tup DESC LIMIT 20;")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_MAINTENANCE__
