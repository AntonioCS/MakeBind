ifndef __MB_MODULES_DOCKER_DOCKER__
__MB_MODULES_DOCKER_DOCKER__ := 1

mb_debug_dk_invoke ?= $(mb_debug)
dk_bin           ?= docker#
dk_bin_options   ?=# global flags if you have any (e.g., DOCKER_HOST)
dk_shell_default ?= /bin/sh#
dk_exec_default_tty ?= -it#



# dk_invoke: like dc_invoke, but for plain `docker` (container-level)
# Args:
#   1: command (required)   e.g., exec | logs | cp | inspect | network ...
#   2: options (optional)   e.g., -it --follow --since 1h
#   3: object  (optional)   e.g., <container> | <image> | <network> ...
#   4: extras  (optional)   e.g., bash -lc "…"  or  /host:/ctr
define dk_invoke
$(strip
	$(eval
		$0_params_command := $(if $(value 1),$(strip $1),$(call mb_printf_error, You must pass a command))
		$0_params_options := $(if $(value 2),$(strip $2))
		$0_params_object  := $(if $(value 3),$(strip $3))
		$0_params_extras  := $(if $(value 4),$(strip $4))
	)

	$(call mb_debug_print, dk_invoke_bin: $($dk_bin),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_bin_options: $(dk_bin_options),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_cmd: $($0_params_command),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_options: $($0_params_options),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_object: $($0_params_object),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_extras: $($0_params_extras),$(mb_debug_dk_invoke))

	$(eval $0_command := $(strip $(dk_bin) $(dk_bin_options) $($0_params_command) $($0_params_options) $($0_params_object) $($0_params_extras)))
	$(call mb_invoke,$($0_command))
)
endef

define dk_shellc
$(strip
	$(eval $0_ctr := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 requires a container)))
	$(eval $0_cmd := $(if $(value 2),$(strip $2),$(call mb_printf_error, $0 requires a command)))
	$(eval $0_sh  := $(if $(value 3),$(strip $3),$(dk_shell_default)))
	$(eval $0_tty := $(if $(value 4),$(strip $4),$(dk_exec_default_tty)))

	$(call dk_invoke,exec,$($0_tty),$($0_ctr),$($0_sh) -c "$(call mb_normalizer,$($0_cmd))")
)
endef

define dk_logs
$(strip
	$(eval $0_ctr := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 requires a container)))
	$(eval $0_opts := $(if $(value 2),$(strip $2),--follow --tail=200))

	$(call dk_invoke,logs,$($0_opts),$($0_ctr))
)
endef

define dk_inspect
$(strip
	$(eval
		$0_obj := $(if $(value 1),$1,$(call mb_printf_error, $0 requires a a name/id))
		$0_fmt := $(if $(value 2),$2)
	)
	$(if $(value $0_fmt), \
		$(call dk_invoke,inspect,--format '$($0_fmt)',$($0_obj)), \
		$(call dk_invoke,inspect,,$($0_obj)) \
	)
)
endef

# $1 = network name
# Returns $(mb_true) if exists, $(mb_false) if not
define dk_network_exists
$(strip
	$(eval $0_network := $(if $(value 1),$(strip $1),$(call mb_printf_error, You must pass a network)))
	$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_on), \
		$(call dk_invoke,network inspect,, $($0_network)) \
		$(call mb_is_last_rc_ok) \
	)
)
endef

######################################################################################


dk/network-default-ensure: ## Ensure that the default network exists
	$(if $(value dc_default_network_name),\
		$(if $(call docker_network_exists,$(dc_default_network_name)),\
			$(call mb_printf_info,Network $(dc_default_network_name) already exists),\
			$(call mb_printf_info,Network $(dc_default_network_name) not found$(mb_comma) creating...) \
			$(call dk_invoke,network create,,$(dc_default_network_name))\
		),\
		$(call mb_printf_warn,dc_default_network_name is empty$(mb_comma) skipping network check)\
	)

dk/nuke-all: ## Remove everything docker related from the system (system prune)
	$(eval dc_nuke_all_msg := Are you sure you want to remove everything?? [y/n])
	$(if $(call mb_user_confirm,$(dc_nuke_all_msg)),
		$(call dk_invoke,system, prune--all --volumes --force)
	,
		$(call mb_printf_info,Nuking all process stopped)
	)


endif # __MB_MODULES_DOCKER_DOCKER__