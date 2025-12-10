#####################################################################################
# Project: MakeBind
# File: tests/unit/core/mb_exec_with_mode_test.mk
# Description: Tests for mb_exec_with_mode function
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/functions.mk

## Note: We don't mock dk_shellc/dc_shellc here because when running all tests,
## the real implementations from docker module may be loaded. Instead, we test
## against the actual output format.

######################################################################################
# Local mode tests
######################################################################################

define test_mb_exec_with_mode_local
$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_off),
	$(eval test_local_exec_mode := local)
	$(eval test_local_bin := /usr/bin/php)
	$(eval $0_result := $(call mb_exec_with_mode,--version,test_local))
	$(call mb_assert_eq,/usr/bin/php --version;,$($0_result))
)
endef

define test_mb_exec_with_mode_local_with_args
$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_off),
	$(eval myapp_exec_mode := local)
	$(eval myapp_bin := composer)
	$(eval $0_result := $(call mb_exec_with_mode,install --no-dev,myapp))
	$(call mb_assert_eq,composer install --no-dev;,$($0_result))
)
endef

######################################################################################
# Docker mode tests
######################################################################################

define test_mb_exec_with_mode_docker
$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_off),
	$(eval dockertest_exec_mode := docker)
	$(eval dockertest_dk_container := my-php-container)
	$(eval $0_result := $(call mb_exec_with_mode,php --version,dockertest))
	$(call mb_assert_contains,docker exec,$($0_result))
	$(call mb_assert_contains,my-php-container,$($0_result))
	$(call mb_assert_contains,php --version,$($0_result))
)
endef

define test_mb_exec_with_mode_docker_custom_shell
$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_off),
	$(eval dkshell_exec_mode := docker)
	$(eval dkshell_dk_container := app-container)
	$(eval dkshell_dk_shell := /bin/bash)
	$(eval dkshell_dk_tty := -i)
	$(eval $0_result := $(call mb_exec_with_mode,echo hello,dkshell))
	$(call mb_assert_contains,docker exec -i,$($0_result))
	$(call mb_assert_contains,/bin/bash,$($0_result))
	$(call mb_assert_contains,echo hello,$($0_result))
)
endef

######################################################################################
# Docker-compose mode tests
######################################################################################

## Note: dc_shellc may not be defined if docker_compose module isn't loaded
## Skip this test if dc_shellc is not available
define test_mb_exec_with_mode_docker_compose
$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_off),
	$(eval dctest_exec_mode := docker-compose)
	$(eval dctest_dc_service := php-fpm)
	$(if $(value dc_shellc),
		$(eval $0_result := $(call mb_exec_with_mode,composer install,dctest))
		$(call mb_assert_contains,exec,$($0_result))
		$(call mb_assert_contains,php-fpm,$($0_result))
	,
		$(call mb_assert,$(mb_true),Skipped - dc_shellc not defined)
	)
)
endef
