
mb_makebind_tmp_path := $(mb_makebind_path)/tmp
mb_makebind_templates_path := $(mb_makebind_path)/templates
mb_core_path := $(abspath $(mb_makebind_path)/core)
mb_core_util_path := $(mb_core_path)/util
mb_core_util_bin_path := $(mb_core_util_path)/bin
mb_modules_path := $(abspath $(mb_makebind_path)/modules)
mb_project_makefile := $(mb_project_path)/Makefile
mb_project_bindhub_path := $(mb_project_path)/bind-hub
## Internal folder for auto-generated files
mb_project_bindhub_internal_path := $(mb_project_bindhub_path)/internal
## Specific modules folder for the project
mb_project_bindhub_modules_path := $(mb_project_bindhub_path)/modules
## Configs for modules
mb_project_bindhub_configs := $(mb_project_bindhub_path)/configs
mb_project_config_file := $(mb_project_bindhub_path)/config.mk
mb_project_config_local_file := $(mb_project_bindhub_path)/config.local.mk
mb_project_file := $(mb_project_bindhub_path)/project.mk
mb_project_local_file := $(mb_project_bindhub_path)/project.local.mk
mb_project_bindhub_internal_modules_file := $(mb_project_bindhub_internal_path)/modules.mk
mb_debug ?= $(mb_off)
# Some functions will not function properly in other shells
mb_default_shell_not_windows ?= /bin/bash
mb_default_target ?= mb/targets-list
mb_auto_include_init_project_if_config_missing ?= $(mb_on)
mb_check_missing_project_files ?= $(mb_true)
## Spacing between targets when listing them
mb_target_column_width ?= 40
mb_target_left_padding ?= 2
## Show only targets from the project and its modules
mb_targets_only_project ?= $(mb_false)#