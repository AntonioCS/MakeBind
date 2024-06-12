mb_project_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
mb_clone_mb_if_not_found ?= 0 # Set this to 1 if you want to have MakeBind cloned automatically if not found
mb_mb_default_path ?= $(abspath $(mb_project_path)/../../../make/MakeBind)
mb_git_clone_path ?= $(dir $(mb_mb_default_path))
mb_main_mk ?= $(mb_mb_default_path)/main.mk
mb_default_repo_ssh ?= git@github.com:AntonioCS/MakeBind.git
mb_silent_mode ?= 0

ifeq ($(if $(value mb_debug),$(mb_debug),0),1)
$(info mb_project_path: $(mb_project_path))
$(info mb_clone_mb_if_not_found: $(mb_clone_mb_if_not_found))
$(info mb_mb_default_path: $(mb_mb_default_path))
$(info mb_git_clone_path: $(mb_git_clone_path))
$(info mb_main_mk: $(mb_main_mk))
$(info mb_default_repo_ssh: $(mb_default_repo_ssh))
$(info mb_silent_mode: $(mb_silent_mode))
endif


## The MakeBind project exists and there is a symlink
ifneq ($(wildcard $(mb_main_mk)),)
include $(mb_main_mk)
else
#### make was called with a target that doesn't exist probably because there is no MakeBind in the project
%:
	@$(MAKE) -s mb_clone_and_rerun mb_invoked_with_target=$*

##### MakeBind is not present in the project, clone it and rerun the make command
mb_clone_and_rerun:
ifeq ($(mb_clone_mb_if_not_found),1)
ifneq ($(mb_silent_mode),1)
	$(info MakeBind being cloned from $(mb_default_repo_ssh) to $(mb_mb_default_path))
endif
	@git clone $(mb_default_repo_ssh) $(mb_git_clone_path)
	@$(MAKE) -s $(if $(value mb_invoked_with_target),$(mb_invoked_with_target))
else
	$(error ERROR: MakeBind is not present in the project, please clone it manually and place it in $(mb_mb_default_path))
endif #($(mb_clone_mb_if_not_found),1)

endif #($(wildcard $(mb_main_mk)),)
