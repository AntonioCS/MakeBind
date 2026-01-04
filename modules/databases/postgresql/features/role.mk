## PostgreSQL Role Management Feature
## Targets: pg/role/create/%, pg/role/drop/%, pg/role/exists/%, pg/role/list
ifndef __MB_PG_FEATURE_ROLE__
__MB_PG_FEATURE_ROLE__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/role/create/%: ## Create role <name> with LOGIN (pg_role_pass=... for password)
	$(call mb_printf_info,Creating role: $*)
	$(if $(value pg_role_pass),\
		$(call pg_invoke,$(pg_psql) -d postgres -Atc \
		"DO \$$\$$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='$*') THEN CREATE ROLE \"$*\" LOGIN PASSWORD '$(pg_role_pass)'; END IF; END \$$\$$;"),\
		$(call pg_invoke,$(pg_psql) -d postgres -Atc \
		"DO \$$\$$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='$*') THEN CREATE ROLE \"$*\" LOGIN; END IF; END \$$\$$;")\
	)

pg/role/drop/%: ## Drop role <name> if exists
	$(call mb_printf_info,Dropping role: $*)
	$(call pg_invoke,$(pg_psql) -d postgres -Atc "DROP ROLE IF EXISTS \"$*\";")

pg/role/exists/%: ## Check if role <name> exists
	$(call mb_printf_info,Checking if role exists: $*)
	@$(pg_env_pass) $(pg_psql) -d postgres -Atc "SELECT 1 FROM pg_roles WHERE rolname='$*';" | grep -q 1 && \
		echo "Role '$*' exists" || \
		echo "Role '$*' does NOT exist"

pg/role/list: ## List all roles with attributes
	$(call mb_printf_info,Listing all roles)
	$(call pg_invoke,$(pg_psql) -d postgres -c "\du")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_ROLE__
