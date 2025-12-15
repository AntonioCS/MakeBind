#####################################################################################
# Terraform Module
# Workflow Automation for Multi-Environment Deployments
#
# Version: 1.0.0
# Author: AntonioCS
# License: MIT
#####################################################################################
# Overview:
#   Provides reusable terraform workflow targets for managing infrastructure
#   across multiple environments (local, dev, staging, prod, etc.)
#
# Prerequisites:
#   - terraform CLI installed and in PATH
#   - Environment directories under tf_env_dir
#
# Key Pattern:
#   make terraform/<command>/<environment>
#
# Examples:
#   make terraform/init/local
#   make terraform/plan/dev
#   make terraform/apply/prod
#
#####################################################################################

ifndef __MB_MODULES_TERRAFORM__
__MB_MODULES_TERRAFORM__ := 1

#####################################################################################
# Helper Functions
#####################################################################################

## @function tf_build_chdir
## @desc Build the -chdir argument or empty string based on tf_chdir_flag
## @arg 1: env (required) - Environment name
## @returns -chdir=<path> or empty string
## @group terraform
define tf_build_chdir
$(strip \
	$(if $(value 1),,$(call mb_printf_error,$0: env required)) \
	$(eval $0_arg1_env := $(strip $1)) \
	$(if $(call mb_is_true,$(tf_chdir_flag)), \
		-chdir=$(tf_env_dir)/$($0_arg1_env) \
	) \
)
endef

## @function tf_build_var_file
## @desc Build -var-file arguments for each file in tf_shared_vars
## @desc Supports multiple space-delimited paths. Use mb_space_guard for paths with spaces.
## @returns -var-file="<path>" for each file, or empty string if tf_shared_vars is empty
## @group terraform
## @example Single file: -var-file="common.tfvars"
## @example Multiple: -var-file="common.tfvars" -var-file="secrets.tfvars"
define tf_build_var_file
$(strip \
	$(if $(value tf_shared_vars), \
		$(foreach $0_file,$(tf_shared_vars), \
			-var-file="$(call mb_space_unguard,$($0_file))" \
		) \
	) \
)
endef

## @function tf_is_auto_approve_env
## @desc Check if environment is in auto-approve list
## @arg 1: env (required) - Environment name
## @returns $(mb_true) if auto-approve, empty otherwise
## @group terraform
define tf_is_auto_approve_env
$(strip \
	$(if $(value 1),,$(call mb_printf_error,$0: env required)) \
	$(eval $0_arg1_env := $(strip $1)) \
	$(if $(filter $($0_arg1_env),$(tf_auto_approve_envs)),$(mb_true)) \
)
endef

## @function tf_run
## @desc Execute terraform command in environment directory
## @desc Automatically includes shared tfvars unless command is in tf_no_var_file_cmds
## @arg 1: env (required) - Environment name (e.g., local, dev, prod)
## @arg 2: command (required) - Terraform command (e.g., init, plan, apply)
## @arg 3: extra_args (optional) - Additional arguments
## @returns Command output via mb_invoke
## @group terraform
## @example $(call tf_run,local,init)
## @example $(call tf_run,dev,plan,-detailed-exitcode)
## @example $(call tf_run,prod,apply,-auto-approve)
## @note Commands in tf_no_var_file_cmds skip -var-file (default: init validate output state)
define tf_run
$(strip \
	$(if $(value 1),,$(call mb_printf_error,$0: env required)) \
	$(if $(value 2),,$(call mb_printf_error,$0: command required)) \
	$(eval $0_arg1_env := $(strip $1)) \
	$(eval $0_arg2_cmd := $(strip $2)) \
	$(eval $0_arg3_extra := $(if $(value 3),$(strip $3))) \
	$(eval $0_chdir := $(call tf_build_chdir,$($0_arg1_env))) \
	$(eval $0_cmd_base := $(firstword $($0_arg2_cmd))) \
	$(eval $0_var_file := $(if $(filter $($0_cmd_base),$(tf_no_var_file_cmds)),,$(call tf_build_var_file))) \
	$(call mb_invoke,$(tf_bin) $($0_chdir) $($0_arg2_cmd) $($0_var_file) $($0_arg3_extra)) \
)
endef

ifndef __MB_TEST_DISCOVERY__
#####################################################################################
# Generic Terraform Targets (pattern rules)
#####################################################################################

terraform/init/%: ## Initialize Terraform for environment (usage: make terraform/init/local)
	$(call mb_printf_info,Initializing Terraform for $* environment...)
	$(call tf_run,$*,init)

terraform/plan/%: ## Plan Terraform changes (usage: make terraform/plan/dev)
	$(call mb_printf_info,Planning Terraform changes for $* environment...)
	$(call tf_run,$*,plan)

terraform/apply/%: ## Apply Terraform changes (usage: make terraform/apply/local)
	$(call mb_printf_info,Applying Terraform for $* environment...)
	$(if $(call tf_is_auto_approve_env,$*), \
		$(call tf_run,$*,apply,-auto-approve), \
		$(call tf_run,$*,apply) \
	)

terraform/destroy/%: ## Destroy Terraform infrastructure (usage: make terraform/destroy/local)
	$(if $(call mb_is_true,$(tf_destroy_confirm)), \
		$(call mb_user_confirm,This will destroy all infrastructure in $* environment!) \
	)
	$(if $(call tf_is_auto_approve_env,$*), \
		$(call tf_run,$*,destroy,-auto-approve), \
		$(call tf_run,$*,destroy) \
	)

terraform/validate/%: ## Validate Terraform configuration (usage: make terraform/validate/local)
	$(call mb_printf_info,Validating Terraform configuration for $*...)
	$(call tf_run,$*,validate)

terraform/output/%: ## Show Terraform outputs (usage: make terraform/output/local)
	$(call tf_run,$*,output)

terraform/state/list/%: ## List Terraform state resources (usage: make terraform/state/list/local)
	$(call tf_run,$*,state list)

terraform/refresh/%: ## Refresh Terraform state (usage: make terraform/refresh/local)
	$(call mb_printf_info,Refreshing Terraform state for $*...)
	$(call tf_run,$*,refresh)

#####################################################################################
# Utility Targets
#####################################################################################

terraform/fmt: ## Format all Terraform files in tf_root_dir
	$(call mb_printf_info,Formatting Terraform files in $(tf_root_dir)...)
	$(call mb_invoke,$(tf_bin) fmt -recursive $(tf_root_dir))

terraform/fmt/check: ## Check if Terraform files are formatted
	$(call mb_printf_info,Checking Terraform formatting in $(tf_root_dir)...)
	$(call mb_invoke,$(tf_bin) fmt -check -recursive $(tf_root_dir))

terraform/version: ## Show Terraform version
	$(call mb_invoke,$(tf_bin) version)

endif # __MB_TEST_DISCOVERY__

endif # __MB_MODULES_TERRAFORM__
