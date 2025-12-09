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
	$(eval mb_invoke_silent := $(mb_on))
	$(eval mb_invoke_run_in_shell := $(mb_off))

	## Setup local mode config
	$(eval test_local_exec_mode := local)
	$(eval test_local_bin := /usr/bin/php)

	$(eval $0_result := $(call mb_exec_with_mode,--version,test_local))
	$(call mb_assert_eq,/usr/bin/php --version;,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_mb_exec_with_mode_local_with_args
	$(eval mb_invoke_silent := $(mb_on))
	$(eval mb_invoke_run_in_shell := $(mb_off))

	## Setup local mode config
	$(eval myapp_exec_mode := local)
	$(eval myapp_bin := composer)

	$(eval $0_result := $(call mb_exec_with_mode,install --no-dev,myapp))
	$(call mb_assert_eq,composer install --no-dev;,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# Docker mode tests
######################################################################################

define test_mb_exec_with_mode_docker
	$(eval mb_invoke_silent := $(mb_on))
	$(eval mb_invoke_run_in_shell := $(mb_off))

	## Setup docker mode config
	$(eval dockertest_exec_mode := docker)
	$(eval dockertest_dk_container := my-php-container)

	$(eval $0_result := $(call mb_exec_with_mode,php --version,dockertest))
	## Result should contain docker exec with container and command
	$(call mb_assert_contains,docker exec,$($0_result))
	$(call mb_assert_contains,my-php-container,$($0_result))
	$(call mb_assert_contains,php --version,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_mb_exec_with_mode_docker_custom_shell
	$(eval mb_invoke_silent := $(mb_on))
	$(eval mb_invoke_run_in_shell := $(mb_off))

	## Setup docker mode with custom shell
	$(eval dkshell_exec_mode := docker)
	$(eval dkshell_dk_container := app-container)
	$(eval dkshell_dk_shell := /bin/bash)
	$(eval dkshell_dk_tty := -i)

	$(eval $0_result := $(call mb_exec_with_mode,echo hello,dkshell))
	## Result should use custom shell and tty flags
	$(call mb_assert_contains,docker exec -i,$($0_result))
	$(call mb_assert_contains,/bin/bash,$($0_result))
	$(call mb_assert_contains,echo hello,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# Docker-compose mode tests
######################################################################################

## Note: dc_shellc may not be defined if docker_compose module isn't loaded
## Skip this test if dc_shellc is not available
define test_mb_exec_with_mode_docker_compose
	$(eval mb_invoke_silent := $(mb_on))
	$(eval mb_invoke_run_in_shell := $(mb_off))

	## Setup docker-compose mode config
	$(eval dctest_exec_mode := docker-compose)
	$(eval dctest_dc_service := php-fpm)

	## Only test if dc_shellc is defined (docker_compose module loaded)
	$(if $(value dc_shellc),
		$(eval $0_result := $(call mb_exec_with_mode,composer install,dctest))
		$(call mb_assert_contains,exec,$($0_result))
		$(call mb_assert_contains,php-fpm,$($0_result))
	,
		$(call mb_assert,$(mb_true),Skipped - dc_shellc not defined)
	)

	$(eval mb_invoke_silent := $(mb_off))
endef
