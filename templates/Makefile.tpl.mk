#####################################################################################
# Project: MakeBind
# File: Project_Makefile.mk
# Description: This is the Makefile to copy over to your project folder and rename to Makefile, once copied remove this header
# Author: AntonioCS
# License: MIT License
#####################################################################################

mb_silent_mode ?= 0
mb_default_location ?= $(abspath $(mb_project_current_dir)/../MakeBind/*)
mb_project_current_dir := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
mb_main_mk := $(mb_project_current_dir)/MakeBind/main.mk

# The MakeBind project exists and there is a symlink
ifneq ($(wildcard $(mb_main_mk)),)

include $(mb_main_mk)

#### The MakeBind project doesn't exist or there is no symlink
else

ifdef CI
mb_silent_mode := 1
endif

mb_default_path ?= $(abspath $(mb_project_current_dir)/../MakeBind/*)
mb_dir := $(dir $(mb_default_path))
mb_default_repo_ssh ?= git@github.com:AntonioCS/MakeBind.git
#$(if $(value mb_github_repo_ssh),$(mb_github_repo_ssh),git@github.com:AntonioCS/MakeBind.git)

#### make was called with a non-existing target because nothing exists
### make was called with a target that doesn't exist probably because there is no MakeBind in the project
%:
	@$(MAKE) -s mb_invoked_with_target=$*

#### MakeBind exists but there is not no symlink
ifneq ($(wildcard $(mb_default_path)),)
mb_create_symlink_and_invoke:
ifndef mb_silent_mode
	$(info Creating symlink to $(mb_dir))
endif
	@ln -s $(mb_dir)
ifndef mb_silent_mode
	@$(MAKE) -s $(if $(value mb_invoked_with_target),$(mb_invoked_with_target))
endif
else

#### MakeBind is not present in the project, clone it and rerun the make command
mb_clone_and_rerun:
ifndef mb_silent_mode
	$(info MakeBind being cloned from $(mb_repo_ssh) to $(mb_dir))
endif
	@git clone $(mb_default_repo_ssh) $(mb_dir)
	@$(MAKE) -s $(if $(value mb_invoked_with_target),mb_invoked_with_target=$(mb_invoked_with_target))
endif

endif
