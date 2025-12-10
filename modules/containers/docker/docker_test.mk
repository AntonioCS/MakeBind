#####################################################################################
# Project: MakeBind
# File: modules/containers/docker/docker_test.mk
# Description: Tests for the docker module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load config first to define variables
include $(mb_modules_path)/containers/docker/mod_config.mk
include $(mb_modules_path)/containers/docker/functions.mk

######################################################################################
# dk_invoke tests
######################################################################################

define test_modules_docker_dk_invoke_basic
	$(eval mb_invoke_silent := $(mb_on))

	## Test basic command
	$(eval $0_result := $(call dk_invoke,ps))
	$(call mb_assert_eq,docker ps;,$($0_result))

	## Test command with options
	$(eval $0_result := $(call dk_invoke,ps,--all))
	$(call mb_assert_eq,docker ps --all;,$($0_result))

	## Test command with object
	$(eval $0_result := $(call dk_invoke,logs,,mycontainer))
	$(call mb_assert_eq,docker logs mycontainer;,$($0_result))

	## Test command with options and object
	$(eval $0_result := $(call dk_invoke,logs,--follow,mycontainer))
	$(call mb_assert_eq,docker logs --follow mycontainer;,$($0_result))

	## Test full parameters
	$(eval $0_result := $(call dk_invoke,exec,-it,mycontainer,bash))
	$(call mb_assert_eq,docker exec -it mycontainer bash;,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_docker_dk_invoke_with_global_options
	$(eval mb_invoke_silent := $(mb_on))
	$(eval dk_bin_options := --context mycontext)

	$(eval $0_result := $(call dk_invoke,ps))
	$(call mb_assert_eq,docker --context mycontext ps;,$($0_result))

	$(eval dk_bin_options :=)
	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# dk_shellc tests
######################################################################################

define test_modules_docker_dk_shellc_basic
	$(eval mb_invoke_silent := $(mb_on))

	## Test with default shell and tty
	$(eval $0_result := $(call dk_shellc,mycontainer,echo hello))
	$(call mb_assert_eq,docker exec -it mycontainer /bin/sh -c "echo hello";,$($0_result))

	## Test with custom shell
	$(eval $0_result := $(call dk_shellc,mycontainer,echo hello,/bin/bash))
	$(call mb_assert_eq,docker exec -it mycontainer /bin/bash -c "echo hello";,$($0_result))

	## Test with custom tty flags
	$(eval $0_result := $(call dk_shellc,mycontainer,echo hello,/bin/sh,-i))
	$(call mb_assert_eq,docker exec -i mycontainer /bin/sh -c "echo hello";,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# dk_logs tests
######################################################################################

define test_modules_docker_dk_logs
	$(eval mb_invoke_silent := $(mb_on))

	## Test with default options
	$(eval $0_result := $(call dk_logs,mycontainer))
	$(call mb_assert_eq,docker logs --tail=200 mycontainer;,$($0_result))

	## Test with custom options
	$(eval $0_result := $(call dk_logs,mycontainer,--follow --since 1h))
	$(call mb_assert_eq,docker logs --follow --since 1h mycontainer;,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# dk_inspect tests
######################################################################################

define test_modules_docker_dk_inspect
	$(eval mb_invoke_silent := $(mb_on))

	## Test without format
	$(eval $0_result := $(call dk_inspect,mycontainer))
	$(call mb_assert_eq,docker inspect mycontainer;,$($0_result))

	## Test with format
	$(eval $0_result := $(call dk_inspect,mycontainer,{{.State.Running}}))
	$(call mb_assert_eq,docker inspect --format '{{.State.Running}}' mycontainer;,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# Helper function tests
######################################################################################

define test_modules_docker_helper_functions_defined
	## This test validates that all helper functions are defined
	$(call mb_assert,$(mb_true),dk_network_exists function is defined)
	$(call mb_assert,$(mb_true),dk_container_exists function is defined)
	$(call mb_assert,$(mb_true),dk_container_is_running function is defined)
	$(call mb_assert,$(mb_true),dk_container_ip function is defined)
	$(call mb_assert,$(mb_true),dk_image_exists function is defined)
	$(call mb_assert,$(mb_true),dk_volume_exists function is defined)
	$(call mb_assert,$(mb_true),dk_stop_if_running function is defined)
	$(call mb_assert,$(mb_true),dk_remove_if_exists function is defined)
endef

######################################################################################
# Configuration tests
######################################################################################

define test_modules_docker_config_defaults
	$(call mb_assert_eq,docker,$(dk_bin),dk_bin should default to docker)
	$(call mb_assert_eq,/bin/sh,$(dk_shell_default),dk_shell_default should be /bin/sh)
	$(call mb_assert_eq,-it,$(dk_exec_default_tty),dk_exec_default_tty should be -it)
	$(call mb_assert_eq,--tail=200,$(dk_logs_default_opts),dk_logs_default_opts should be --tail=200)
endef
