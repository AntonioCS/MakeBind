mb_debug_makefile ?= $(if $(value mb_debug),$(mb_debug))## Debug flag for Makefile (set to empty by default)
mb_project_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))## This projects path
mb_mb_default_path ?= $(abspath $(mb_project_path)/../MakeBind)## This is the default path for MakeBind in your system, change it if needed
mb_main_mk ?= $(mb_mb_default_path)/main.mk## This is the main entry point for MakeBind
mb_latest_url ?= https://api.github.com/repos/AntonioCS/MakeBind/releases/latest## Github API URL to get the latest release
mb_auto_install_if_missing ?= 1## If MakeBind is not found in the project, should it be downloaded?
mb_silent_mode ?= 0## Should MakeBind be silent? Useful when in CI/CD
mb_has_main_mk ?= $(wildcard $(mb_main_mk))## Check if MakeBind is present in system

ifeq ($(mb_debug_makefile),0)
override mb_debug_makefile :=## Make it empty for code simplicity
endif

ifeq ($(mb_debug_makefile),1)
$(info mb_project_path: $(mb_project_path))
$(info mb_mb_default_path: $(mb_mb_default_path))
$(info mb_main_mk: $(mb_main_mk))
$(info mb_latest_url: $(mb_latest_url))
$(info mb_auto_install_if_missing: $(mb_auto_install_if_missing))
$(info mb_silent_mode: $(mb_silent_mode))
$(info mb_has_main_mk: $(mb_has_main_mk))
endif

ifneq ($(mb_has_main_mk),)## The MakeBind project exists

include $(mb_main_mk)

else
.PHONY: mb_install

__MB_DOWNLOAD_LATEST_MB__ := 1
$(if $(mb_debug_makefile),$(warning DEBUG: MakeBind is not found in $(mb_mb_default_path)))

### NOTE: This is a catch all target for when the project is not present in the system and it was called with a target
%:
	@$(MAKE) -s mb_install mb_invoked_with_target=$*

##### MakeBind is not present in the project, fetch latest release from github
ifneq ($(mb_auto_install_if_missing),1)
mb_install:
	$(error ERROR: MakeBind is not present in the project and auto install is disabled, please downloadt it from https://github.com/AntonioCS/MakeBind/releases and place it in $(mb_mb_default_path))
else
mb_install:
ifneq ($(mb_silent_mode),1)
	$(info MakeBind being fetched from $(mb_latest_url) and installed into $(mb_mb_default_path))
endif
	$(call mb_zip_path_generate)
	$(call mb_latest_release_url_generate)
	$(call mb_download_latest_mb)
	$(call mb_install)
	@$(MAKE) -s $(if $(value mb_invoked_with_target),$(mb_invoked_with_target))

endif #($(mb_auto_install_if_missing),1)

endif #($(wildcard $(mb_main_mk)),)


ifdef __MB_DOWNLOAD_LATEST_MB__

mb_os_is_windows := $(if $(and $(value OS),$(findstring Windows_NT,$(OS))),1)## Empty if not windows, 1 if windows
mb_makefile_debug = $(if $(mb_debug_makefile),$(info DEBUG: $(strip $1)))

define mb_makefile_run_for_os
$(strip
	$(eval mb_run_for_os_cmd := $(strip $(if $(mb_os_is_windows),$1,$2)))
	$(call mb_makefile_debug, Running cmd: $(subst $(mb_dollar),$$,$(mb_run_for_os_cmd)))
	$(shell $(subst $(mb_dollar),$$,$(mb_run_for_os_cmd)))
)
endef

define mb_zip_path_generate
	$(eval mb_tmp_path := $(if $(mb_os_is_windows),$(abspath $(shell powershell -Command "[System.IO.Path]::GetTempPath()")),/tmp))
	$(eval mb_zip_path := $(mb_tmp_path)/mb.zip)
	$(call mb_makefile_debug, mb_tmp_path: $(mb_tmp_path))
	$(call mb_makefile_debug, mb_zip_path: $(mb_zip_path))
endef

mb_comma := ,## Comma for sed command which is inside a make function
mb_dollar := __DOLLAR__## Dollar sign for powershell command which is inside a make function
mb_powershell = powershell -Command '$(strip $1)'

define mb_latest_release_url_generate
$(strip
	$(eval mb_latest_releate_url := $(call mb_makefile_run_for_os,\
		$(call mb_powershell,$(mb_dollar)response = Invoke-RestMethod -Uri "$(mb_latest_url)"; Write-Output $(mb_dollar)response.zipball_url), \
		curl -s $(mb_latest_url) | grep '"zipball_url":' | sed -E 's/.*"zipball_url": "(.*)"$(mb_comma)/\1/' \
	))
	$(if $(mb_debug_makefile),$(info DEBUG: Latest URL: $(mb_latest_releate_url)))
)
endef

define mb_download_latest_mb
$(call mb_makefile_run_for_os,
	$(call mb_powershell,Invoke-WebRequest -Uri $(mb_latest_releate_url) -OutFile $(mb_zip_path)),
	curl -s -L -o $(mb_zip_path) $(mb_latest_releate_url)
)
endef


###NOTE: I need to check for wrong folder structure if on windows with msys2
define mb_install
$(strip
$(eval mb_parent_folder := $(abspath $(dir $(mb_mb_default_path))))
$(if $(and $(mb_os_is_windows),$(filter /%,$(mb_parent_folder))),
	$(eval mb_no_leading_slash := $(patsubst /%,%,$(mb_parent_folder)))
	$(eval mb_drive_letter := $(word 1,$(strip $(subst /, ,$(mb_no_leading_slash)))))
	$(eval mb_parent_folder := $(mb_drive_letter):/$(patsubst $(mb_drive_letter)/%,%,$(mb_no_leading_slash)))
)
$(call mb_makefile_run_for_os,
	$(call mb_powershell,Expand-Archive -Path $(mb_zip_path) -DestinationPath $(mb_parent_folder)),
	unzip -nqq $(mb_zip_path) -d $(mb_parent_folder)
)

$(call mb_makefile_run_for_os,
	$(call mb_powershell,$(mb_dollar)folder = Get-ChildItem -Path "$(mb_parent_folder)" -Depth 1 -Directory -Filter "*-MakeBind-*" | \
	Select-Object -First 1; if ($(mb_dollar)folder) { Move-Item -Path $(mb_dollar)folder.FullName -Destination "$(mb_parent_folder)/MakeBind" }),
    mv "`find $(mb_parent_folder) -maxdepth 1 -type d -name '*-MakeBind-*'`" "$(mb_parent_folder)/MakeBind"
))
endef

endif # __MB_DOWNLOAD_LATEST_MB__
