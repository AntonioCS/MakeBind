#####################################################################################
# Project: MakeBind
# File: modules/databases/postgresql/postgresql.mk
# Description: PostgreSQL database module with feature-based target loading
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_POSTGRESQL__
__MB_MODULES_POSTGRESQL__ := 1

## Available features: core sql db role conn session dump extension table index maintenance
pg_available_features := core sql db role conn session dump extension table index maintenance

## Validate pg_features - warn if unknown feature requested
$(foreach f,$(pg_features),\
	$(if $(filter $(f),$(pg_available_features)),,\
		$(warning PostgreSQL: Unknown feature '$(f)'. Available: $(pg_available_features))))

## =============================================================================
## Shared variables (used by all features)
## =============================================================================

pg_env                := $(if $(pg_pass),PGPASSWORD=$(pg_pass))
pg_user_flags         := -U $(pg_user)
pg_host_flags         := -h $(pg_host) -p $(pg_port)
pg_psql_common        := -v ON_ERROR_STOP=1
pg_now                := $(shell date +%Y%m%d_%H%M%S)

## =============================================================================
## pg_invoke - Execute PostgreSQL commands with mode support
## =============================================================================
## Supports 3 execution modes:
##   - local:          Run command directly on host
##   - docker:         Run via docker exec in pg_dk_container
##   - docker-compose: Run via docker compose exec in pg_dc_service
##
## Auto-extracts the binary (first word) from the command and sets pg_bin,
## then passes the remaining args to mb_exec_with_mode.
##
## @arg 1: command - Full command to execute (e.g., "psql -d mydb -c 'SELECT 1'")
## @example $(call pg_invoke,psql -d mydb -c "SELECT 1")
## @example $(call pg_invoke,pg_dump -F c mydb > backup.dump)

define pg_invoke
$(strip
	$(eval pg_bin := $(firstword $1))
	$(call mb_exec_with_mode,$(wordlist 2,999,$1),pg)
)
endef

## Pre-built command fragments for convenience
pg_psql    = psql $(pg_host_flags) $(pg_user_flags) $(pg_psql_common)
pg_dump    = pg_dump $(pg_host_flags) $(pg_user_flags)
pg_restore = pg_restore $(pg_host_flags) $(pg_user_flags)

## =============================================================================
## Feature loader
## =============================================================================

pg_features_path := $(dir $(lastword $(MAKEFILE_LIST)))features

$(foreach feature,$(pg_features),\
	$(if $(wildcard $(pg_features_path)/$(feature).mk),\
		$(eval include $(pg_features_path)/$(feature).mk),\
		$(warning PostgreSQL: Feature file not found: $(pg_features_path)/$(feature).mk)))

endif # __MB_MODULES_POSTGRESQL__
