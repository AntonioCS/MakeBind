#####################################################################################
# Project: MakeBind
# File: modules/infrastructure/terraform/terraform_test.mk
# Description: Tests for the terraform module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load terraform module
include $(mb_modules_path)/infrastructure/terraform/mod_config.mk
include $(mb_modules_path)/infrastructure/terraform/terraform.mk

######################################################################################
# tf_build_chdir tests
######################################################################################

define test_modules_terraform_build_chdir_with_flag
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_chdir_flag := $(mb_true))
	$(eval tf_env_dir := terraform/environments)

	$(eval $0_result := $(call tf_build_chdir,local))
	$(call mb_assert_eq,-chdir=terraform/environments/local,$($0_result))

	$(eval $0_result := $(call tf_build_chdir,dev))
	$(call mb_assert_eq,-chdir=terraform/environments/dev,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_build_chdir_without_flag
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_chdir_flag := $(mb_false))

	$(eval $0_result := $(call tf_build_chdir,local))
	$(call mb_assert_empty,$($0_result))

	$(eval tf_chdir_flag := $(mb_true))
	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_build_chdir_error_without_env
	$(eval mb_invoke_silent := $(mb_on))

	$(call mb_assert_was_called,mb_printf_error,1)
	$(eval $0_result := $(call tf_build_chdir,))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# tf_build_var_file tests
######################################################################################

define test_modules_terraform_build_var_file_single
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_shared_vars := ../../shared/common.tfvars)

	$(eval $0_result := $(call tf_build_var_file))
	$(call mb_assert_contains,-var-file="../../shared/common.tfvars",$($0_result))

	$(eval tf_shared_vars :=)
	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_build_var_file_multiple
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_shared_vars := ../../shared/common.tfvars ../../shared/secrets.tfvars)

	$(eval $0_result := $(call tf_build_var_file))
	$(call mb_assert_contains,-var-file="../../shared/common.tfvars",$($0_result))
	$(call mb_assert_contains,-var-file="../../shared/secrets.tfvars",$($0_result))

	$(eval tf_shared_vars :=)
	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_build_var_file_empty
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_shared_vars :=)

	$(eval $0_result := $(call tf_build_var_file))
	$(call mb_assert_empty,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# tf_is_auto_approve_env tests
######################################################################################

define test_modules_terraform_is_auto_approve_env_match
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_auto_approve_envs := local dev)

	$(eval $0_result := $(call tf_is_auto_approve_env,local))
	$(call mb_assert_eq,$(mb_true),$($0_result))

	$(eval $0_result := $(call tf_is_auto_approve_env,dev))
	$(call mb_assert_eq,$(mb_true),$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_is_auto_approve_env_no_match
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_auto_approve_envs := local)

	$(eval $0_result := $(call tf_is_auto_approve_env,prod))
	$(call mb_assert_empty,$($0_result))

	$(eval $0_result := $(call tf_is_auto_approve_env,staging))
	$(call mb_assert_empty,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# tf_run tests
######################################################################################

define test_modules_terraform_run_basic
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_bin := terraform)
	$(eval tf_chdir_flag := $(mb_true))
	$(eval tf_env_dir := terraform/environments)
	$(eval tf_shared_vars :=)

	$(eval $0_result := $(call tf_run,local,init))
	$(call mb_assert_contains,terraform,$($0_result))
	$(call mb_assert_contains,-chdir=terraform/environments/local,$($0_result))
	$(call mb_assert_contains,init,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_run_with_extra_args
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_bin := terraform)
	$(eval tf_chdir_flag := $(mb_true))
	$(eval tf_env_dir := terraform/environments)
	$(eval tf_shared_vars :=)

	$(eval $0_result := $(call tf_run,dev,plan,-detailed-exitcode))
	$(call mb_assert_contains,terraform,$($0_result))
	$(call mb_assert_contains,-chdir=terraform/environments/dev,$($0_result))
	$(call mb_assert_contains,plan,$($0_result))
	$(call mb_assert_contains,-detailed-exitcode,$($0_result))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_run_with_shared_vars
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_bin := terraform)
	$(eval tf_chdir_flag := $(mb_true))
	$(eval tf_env_dir := terraform/environments)
	$(eval tf_shared_vars := ../../shared/common.tfvars)

	$(eval $0_result := $(call tf_run,local,plan))
	$(call mb_assert_contains,terraform,$($0_result))
	$(call mb_assert_contains,-chdir=terraform/environments/local,$($0_result))
	$(call mb_assert_contains,plan,$($0_result))
	$(call mb_assert_contains,-var-file="../../shared/common.tfvars",$($0_result))

	$(eval tf_shared_vars :=)
	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_run_no_var_file_cmds
	$(eval mb_invoke_silent := $(mb_on))
	$(eval tf_bin := terraform)
	$(eval tf_chdir_flag := $(mb_true))
	$(eval tf_env_dir := terraform/environments)
	$(eval tf_shared_vars := ../../shared/common.tfvars)
	$(eval tf_no_var_file_cmds := init validate output state)

	## Commands in tf_no_var_file_cmds should NOT include -var-file
	$(eval $0_result := $(call tf_run,local,validate))
	$(call mb_assert_contains,terraform,$($0_result))
	$(call mb_assert_contains,validate,$($0_result))
	$(call mb_assert_not_empty,$(findstring -chdir,$($0_result)))
	$(call mb_assert_empty,$(findstring -var-file,$($0_result)),validate should not have -var-file)

	## Test init (also in the list)
	$(eval $0_result := $(call tf_run,local,init))
	$(call mb_assert_empty,$(findstring -var-file,$($0_result)),init should not have -var-file)

	## Test state list (multi-word command, first word is "state")
	$(eval $0_result := $(call tf_run,local,state list))
	$(call mb_assert_contains,state list,$($0_result))
	$(call mb_assert_empty,$(findstring -var-file,$($0_result)),state should not have -var-file)

	## Test plan (NOT in list) - should include -var-file
	$(eval $0_result := $(call tf_run,local,plan))
	$(call mb_assert_not_empty,$(findstring -var-file,$($0_result)),plan should have -var-file)

	$(eval tf_shared_vars :=)
	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_run_error_without_env
	$(eval mb_invoke_silent := $(mb_on))

	## Expects 2 calls due to cascading:
	##   1. tf_run: env required
	##   2. tf_build_chdir: env required (called internally)
	$(call mb_assert_was_called,mb_printf_error,2)
	$(eval $0_result := $(call tf_run,,init))

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_terraform_run_error_without_command
	$(eval mb_invoke_silent := $(mb_on))

	$(call mb_assert_was_called,mb_printf_error,1)
	$(eval $0_result := $(call tf_run,local,))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# Configuration tests
######################################################################################

define test_modules_terraform_config_defaults
	## Reset to defaults
	$(eval tf_bin := terraform)
	$(eval tf_root_dir := terraform)
	$(eval tf_env_dir := terraform/environments)
	$(eval tf_default_env := local)
	$(eval tf_auto_approve_envs := local)
	$(eval tf_destroy_confirm := $(mb_true))
	$(eval tf_chdir_flag := $(mb_true))
	$(eval tf_no_var_file_cmds := init validate output state)

	$(call mb_assert_eq,terraform,$(tf_bin))
	$(call mb_assert_eq,terraform,$(tf_root_dir))
	$(call mb_assert_eq,terraform/environments,$(tf_env_dir))
	$(call mb_assert_eq,local,$(tf_default_env))
	$(call mb_assert_eq,local,$(tf_auto_approve_envs))
	$(call mb_assert_eq,$(mb_true),$(tf_destroy_confirm))
	$(call mb_assert_eq,$(mb_true),$(tf_chdir_flag))
	$(call mb_assert_eq,init validate output state,$(tf_no_var_file_cmds))
endef

######################################################################################
# Function definition tests
######################################################################################

define test_modules_terraform_functions_defined
	$(call mb_assert,$(value tf_build_chdir),tf_build_chdir function should be defined)
	$(call mb_assert,$(value tf_build_var_file),tf_build_var_file function should be defined)
	$(call mb_assert,$(value tf_is_auto_approve_env),tf_is_auto_approve_env function should be defined)
	$(call mb_assert,$(value tf_run),tf_run function should be defined)
endef
