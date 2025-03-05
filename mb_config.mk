
mb_makebind_tmp_path := $(mb_makebind_path)/tmp
mb_makebind_templates_path := $(mb_makebind_path)/templates
mb_core_path := $(abspath $(mb_makebind_path)/core)
mb_modules_path := $(abspath $(mb_makebind_path)/modules)
mb_project_makefile := $(mb_project_path)/Makefile
mb_project_bindhub_path := $(mb_project_path)/bind-hub
## Specific modules folder for the project
mb_project_bindhub_modules_path := $(mb_project_bindhub_path)/modules
mb_project_mb_config_file := $(mb_project_bindhub_path)/mb_config.mk
mb_project_mb_config_local_file := $(mb_project_bindhub_path)/mb_config.local.mk
mb_project_mb_project_mk_file := $(mb_project_bindhub_path)/mb_project.mk
mb_project_mb_project_mk_local_file := $(mb_project_bindhub_path)/mb_project.local.mk
mb_project_bindhub_modules_file := $(mb_project_bindhub_path)/mb_modules.mk
mb_debug ?= $(mb_off)
# Some functions will not function properly in other shells
mb_default_shell_not_windows ?= /bin/bash
mb_default_target ?= mb/targets-list
mb_auto_include_init_project_if_config_missing ?= $(mb_on)
mb_check_missing_project_files ?= $(mb_true)