#####################################################################################
# Terraform Module Configuration
#####################################################################################

## @var tf_bin
## @desc Path to terraform binary
## @type string
## @default terraform
## @group terraform
tf_bin ?= terraform

## @var tf_root_dir
## @desc Root terraform directory (for fmt, validate operations)
## @type string
## @default terraform
## @group terraform
tf_root_dir ?= terraform

## @var tf_env_dir
## @desc Environment directory relative to project root
## @type string
## @default terraform/environments
## @group terraform
## @example tf_env_dir=infra/envs make terraform/plan/dev
tf_env_dir ?= terraform/environments

## @var tf_shared_vars
## @desc Shared tfvars file paths, space-delimited (relative to environment directory)
## @desc For paths with spaces, use mb_space_guard: $(call mb_space_guard,path with spaces/file.tfvars)
## @type string
## @default (empty - no shared vars)
## @group terraform
## @example tf_shared_vars=../../shared/common.tfvars
## @example tf_shared_vars=../../shared/common.tfvars ../../shared/secrets.tfvars
tf_shared_vars ?=

## @var tf_default_env
## @desc Default environment name for convenience targets
## @type string
## @default local
## @group terraform
tf_default_env ?= local

## @var tf_auto_approve_envs
## @desc Space-separated list of environments where auto-approve is enabled
## @type string
## @default local
## @group terraform
## @example tf_auto_approve_envs=local dev
tf_auto_approve_envs ?= local

## @var tf_destroy_confirm
## @desc Require confirmation before destroy operations
## @type boolean
## @default $(mb_true)
## @group terraform
tf_destroy_confirm ?= $(mb_true)

## @var tf_chdir_flag
## @desc Use -chdir flag (requires terraform 0.14+)
## @type boolean
## @default $(mb_true)
## @group terraform
tf_chdir_flag ?= $(mb_true)

## @var tf_no_var_file_cmds
## @desc Space-separated list of terraform commands that don't support -var-file
## @type string
## @default init validate output state
## @group terraform
tf_no_var_file_cmds ?= init validate output state
