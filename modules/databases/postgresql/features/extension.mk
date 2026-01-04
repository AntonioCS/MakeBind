## PostgreSQL Extension Management Feature
## Targets: pg/extension/list, pg/extension/available, pg/extension/create/%, pg/extension/drop/%
ifndef __MB_PG_FEATURE_EXTENSION__
__MB_PG_FEATURE_EXTENSION__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/extension/list: ## List installed extensions
	$(call mb_printf_info,Listing installed extensions in '$(pg_db)')
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT extname$(mb_comma) extversion$(mb_comma) extnamespace::regnamespace as schema FROM pg_extension ORDER BY extname;")

pg/extension/available: ## List available (installable) extensions
	$(call mb_printf_info,Listing available extensions)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -c \
	"SELECT name$(mb_comma) default_version$(mb_comma) comment FROM pg_available_extensions ORDER BY name;")

pg/extension/create/%: ## Create/install extension (make pg/extension/create/uuid-ossp)
	$(call mb_printf_info,Creating extension: $*)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "CREATE EXTENSION IF NOT EXISTS \"$*\";")

pg/extension/drop/%: ## Drop extension
	$(call mb_printf_info,Dropping extension: $*)
	$(call pg_invoke,$(pg_psql) -d $(pg_db) -Atc "DROP EXTENSION IF EXISTS \"$*\";")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_EXTENSION__
