## PostgreSQL Dump & Restore Feature
## Targets: pg/dump, pg/restore, pg/dump/list, pg/dump/info
ifndef __MB_PG_FEATURE_DUMP__
__MB_PG_FEATURE_DUMP__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/dump: ## Dump database to file (pg_dump_file=... to override path)
	$(call mb_printf_info,Dumping '$(pg_db)' with format=$(pg_dump_format))
	$(eval $@_file := $(if $(value pg_dump_file),$(pg_dump_file),$(pg_dump_dir)/$(pg_db)_$(pg_now).dump))
	$(call mb_invoke,mkdir -p $(pg_dump_dir))
	$(call pg_invoke,$(pg_dump) -F $(pg_dump_format) $(pg_dump_flags) -f "$($@_file)" "$(pg_db)")
	$(call mb_printf_info,Created $($@_file))

pg/restore: ## Restore from dump file (pg_dump_file=<path> required)
	$(call mb_printf_info,Restoring into '$(pg_db)' from $(pg_dump_file))
	$(if $(value pg_dump_file),,$(error Please provide pg_dump_file=<path to dump>))
	$(call pg_invoke,$(pg_restore) $(pg_restore_flags) -d "$(pg_db)" "$(pg_dump_file)")

pg/dump/list: ## List available dump files
	$(call mb_printf_info,Listing dumps in $(pg_dump_dir))
	$(if $(wildcard $(pg_dump_dir)),\
		$(if $(wildcard $(pg_dump_dir)/*.dump),\
			$(call mb_invoke,ls -lh $(pg_dump_dir)/*.dump),\
			$(info No dumps found in $(pg_dump_dir))),\
		$(info Dump directory $(pg_dump_dir) does not exist))

pg/dump/info: ## Show contents of a dump file (pg_dump_file=<path> required)
	$(call mb_printf_info,Listing contents of $(pg_dump_file))
	$(if $(value pg_dump_file),,$(error Please provide pg_dump_file=<path to dump>))
	$(call mb_invoke,pg_restore -l "$(pg_dump_file)")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_DUMP__
