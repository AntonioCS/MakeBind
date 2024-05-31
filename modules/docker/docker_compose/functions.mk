#####################################################################################
# Project: MakeBind
# File: modules/docker/functions.mk
# Description: Docker functions for MakeBind
# Author: AntonioCS
# License: MIT License
# Notes: Do not include this file directly. It is included in the docker_compose.mk
#####################################################################################
ifndef __MB_MODULES_DOCKER_FUNCTIONS__
__MB_MODULES_DOCKER_FUNCTIONS__ := 1

define dc_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(eval
		dc_invoke_bin := $(if $(value dc_bin),$(dc_bin),docker compose)
		dc_invoke_bin_options := $(if $(value dc_bin_options),$(dc_bin_options))
		dc_invoke_all_dc_files := $(if $(value dc_files),$(addprefix --file ,$(dc_files)))
		dc_invoke_all_dc_env_files := $(if $(value dc_env_files),$(addprefix --env-file ,$(dc_env_files)))
		dc_invoke_cmd := $1
		dc_invoke_options := $(if $(value 2),$2)
		dc_invoke_services := $(if $(value 3),$3)
		dc_invoke_extra := $(if $(value 4),$(strip $4))
		dc_invoke_cmd_options := $(if $(value dc_cmd_options_$1),$(dc_cmd_options_$1))
		dc_invoke_cmd_services := $(if $(value dc_cmd_services_$1),$(dc_cmd_services_$1))
		dc_invoke_cmd_extras := $(if $(value dc_cmd_extras_$1),$(dc_cmd_extras_$1))
	)
	$(eval dc_invoke_command := $(strip $(dc_invoke_bin)
			$(dc_invoke_bin_options)
			$(dc_invoke_all_dc_files)
			$(dc_invoke_all_dc_env_files)
			$(dc_invoke_cmd)
			$(dc_invoke_options)
			$(dc_invoke_cmd_options)
			$(dc_invoke_services)
			$(dc_invoke_cmd_services)
			$(dc_invoke_extra)
			$(dc_invoke_cmd_extras)
		)
	)
	$(call mb_invoke,$(dc_invoke_command))
)
endef

dc_shellc_default_shell_bin ?= sh
dc_shellc_default_cmd ?= exec

define dc_shellc
$(strip
	$(eval dc_shellc_service := $1)
	$(eval dc_shellc_selected_shell_bin := $(if $(value 3),$3,$(dc_shellc_default_shell_bin)))
	$(call dc_invoke,$(dc_shellc_default_cmd),,$(dc_shellc_service),$(dc_shellc_selected_shell_bin) -c "$(call mb_normalizer,$2)")
)
endef

endif # __MB_MODULES_DOCKER_FUNCTIONS__
