#####################################################################################
# Project: MakeBind
# File: modules/databases/postgresql/postgresql_test.mk
# Description: Tests for the PostgreSQL module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load config to define variables
include $(mb_modules_path)/databases/postgresql/mod_config.mk

######################################################################################
# Configuration tests
######################################################################################

define test_modules_postgresql_config_defaults
	$(call mb_assert_eq,core sql db dump maintenance,$(pg_features),pg_features should have default features)
	$(call mb_assert_eq,local,$(pg_exec_mode),pg_exec_mode should default to local)
	$(call mb_assert_eq,postgres,$(pg_user),pg_user should default to postgres)
	$(call mb_assert_eq,app,$(pg_db),pg_db should default to app)
	$(call mb_assert_eq,127.0.0.1,$(pg_host),pg_host should default to 127.0.0.1)
	$(call mb_assert_eq,5432,$(pg_port),pg_port should default to 5432)
	$(call mb_assert_eq,postgres,$(pg_dc_service),pg_dc_service should default to postgres)
	$(call mb_assert_eq,backups,$(pg_dump_dir),pg_dump_dir should default to backups)
	$(call mb_assert_eq,c,$(pg_dump_format),pg_dump_format should default to c)
	$(call mb_assert_eq,30,$(pg_idle_timeout),pg_idle_timeout should default to 30)
	$(call mb_assert_eq,60,$(pg_long_query_threshold),pg_long_query_threshold should default to 60)
endef

define test_modules_postgresql_available_features
	$(call mb_assert_not_empty,$(pg_available_features),pg_available_features should be defined)
	$(call mb_assert_filter,core,$(pg_available_features),core should be an available feature)
	$(call mb_assert_filter,sql,$(pg_available_features),sql should be an available feature)
	$(call mb_assert_filter,db,$(pg_available_features),db should be an available feature)
	$(call mb_assert_filter,role,$(pg_available_features),role should be an available feature)
	$(call mb_assert_filter,conn,$(pg_available_features),conn should be an available feature)
	$(call mb_assert_filter,session,$(pg_available_features),session should be an available feature)
	$(call mb_assert_filter,dump,$(pg_available_features),dump should be an available feature)
	$(call mb_assert_filter,extension,$(pg_available_features),extension should be an available feature)
	$(call mb_assert_filter,table,$(pg_available_features),table should be an available feature)
	$(call mb_assert_filter,index,$(pg_available_features),index should be an available feature)
	$(call mb_assert_filter,maintenance,$(pg_available_features),maintenance should be an available feature)
endef

######################################################################################
# Command building tests
######################################################################################

## Load the main module to test command building
include $(mb_modules_path)/databases/postgresql/postgresql.mk

define test_modules_postgresql_psql_cmd_fragments
	$(call mb_assert_contains,psql,$(pg_psql),pg_psql should contain psql)
	$(call mb_assert_contains,-U $(pg_user),$(pg_psql),pg_psql should contain user flag)
	$(call mb_assert_contains,-h $(pg_host),$(pg_psql),pg_psql should contain host flag)
	$(call mb_assert_contains,-p $(pg_port),$(pg_psql),pg_psql should contain port flag)
endef

define test_modules_postgresql_dump_cmd_fragments
	$(call mb_assert_contains,pg_dump,$(pg_dump),pg_dump should contain pg_dump)
	$(call mb_assert_contains,-U $(pg_user),$(pg_dump),pg_dump should contain user flag)
	$(call mb_assert_contains,-h $(pg_host),$(pg_dump),pg_dump should contain host flag)
endef

define test_modules_postgresql_restore_cmd_fragments
	$(call mb_assert_contains,pg_restore,$(pg_restore),pg_restore should contain pg_restore)
	$(call mb_assert_contains,-U $(pg_user),$(pg_restore),pg_restore should contain user flag)
	$(call mb_assert_contains,-h $(pg_host),$(pg_restore),pg_restore should contain host flag)
endef

define test_modules_postgresql_pg_invoke_defined
	$(call mb_assert,$(value pg_invoke),pg_invoke function should be defined)
endef

define test_modules_postgresql_exec_mode_config
	$(call mb_assert_eq,postgres,$(pg_dk_container),pg_dk_container should default to postgres)
	$(call mb_assert_eq,postgres,$(pg_dc_service),pg_dc_service should default to postgres)
	$(call mb_assert_eq,/bin/bash,$(pg_dk_shell),pg_dk_shell should default to /bin/bash)
	$(call mb_assert_eq,/bin/bash,$(pg_dc_shell),pg_dc_shell should default to /bin/bash)
endef

######################################################################################
# Feature loading tests
######################################################################################

define test_modules_postgresql_feature_core_loaded
	$(call mb_assert,$(filter core,$(pg_features)),core feature should be in pg_features)
	$(call mb_assert,$(value __MB_PG_FEATURE_CORE__),core feature guard should be defined)
endef

define test_modules_postgresql_feature_dump_loaded
	$(call mb_assert,$(filter dump,$(pg_features)),dump feature should be in pg_features)
	$(call mb_assert,$(value __MB_PG_FEATURE_DUMP__),dump feature guard should be defined)
endef

define test_modules_postgresql_feature_maintenance_loaded
	$(call mb_assert,$(filter maintenance,$(pg_features)),maintenance feature should be in pg_features)
	$(call mb_assert,$(value __MB_PG_FEATURE_MAINTENANCE__),maintenance feature guard should be defined)
endef
