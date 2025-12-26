#####################################################################################
# Project: MakeBind
# File: modules/containers/docker/functions.mk
# Description: Docker utility functions
# Author: AntonioCS
# License: MIT License
#####################################################################################

######################################################################################
# Core Functions
######################################################################################

## dk_invoke: Execute docker commands with consistent parameter handling
## Args:
##   1: command (required)   e.g., exec | logs | cp | inspect | network ...
##   2: options (optional)   e.g., -it --follow --since 1h
##   3: object  (optional)   e.g., <container> | <image> | <network> ...
##   4: extras  (optional)   e.g., bash -lc "…"  or  /host:/ctr
define dk_invoke
$(strip
	$(eval
		$0_params_command := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a command))
		$0_params_options := $(if $(value 2),$(strip $2))
		$0_params_object  := $(if $(value 3),$(strip $3))
		$0_params_extras  := $(if $(value 4),$(strip $4))
	)

	$(call mb_debug_print, dk_invoke_bin: $(dk_bin),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_bin_options: $(dk_bin_options),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_cmd: $($0_params_command),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_options: $($0_params_options),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_object: $($0_params_object),$(mb_debug_dk_invoke))
	$(call mb_debug_print, dk_invoke_extras: $($0_params_extras),$(mb_debug_dk_invoke))

	$(eval $0_command := $(strip $(dk_bin) $(dk_bin_options) $($0_params_command) $($0_params_options) $($0_params_object) $($0_params_extras)))
	$(call mb_invoke,$($0_command))
)
endef

## dk_shellc: Execute shell command in container
## Args:
##   1: container (required)
##   2: command (required)
##   3: shell (optional, default: dk_shell_default)
##   4: tty flags (optional, default: dk_exec_default_tty)
##   5: docker command to be uses, exec or run (optional, default: dk_exec_default_dk_cmd)
define dk_shellc
$(strip
	$(eval $0_ctr := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - requires a container)))
	$(eval $0_cmd := $(if $(value 2),$(strip $2),$(call mb_printf_error, $0 - requires a command)))
	$(eval $0_sh  := $(if $(value 3),$(strip $3),$(dk_shell_default)))
	$(eval $0_tty := $(if $(value 4),$(strip $4),$(dk_exec_default_tty)))
	$(eval $0_dk_cmd := $(if $(value 5),$(strip $5),$(dk_exec_default_dk_cmd)))

	$(call dk_invoke,$($0_dk_cmd),$($0_tty),$($0_ctr),$($0_sh) -c "$(call mb_normalizer,$($0_cmd))")
)
endef

## dk_logs: Show container logs
## Args:
##   1: container (required)
##   2: options (optional, default: dk_logs_default_opts)
define dk_logs
$(strip
	$(eval $0_ctr := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - requires a container)))
	$(eval $0_opts := $(if $(value 2),$(strip $2),$(dk_logs_default_opts)))

	$(call dk_invoke,logs,$($0_opts),$($0_ctr))
)
endef

## dk_inspect: Inspect docker object (container, image, network, volume)
## Args:
##   1: object name/id (required)
##   2: format string (optional)
define dk_inspect
$(strip
	$(eval
		$0_obj := $(if $(value 1),$1,$(call mb_printf_error, $0 - requires a name/id))
		$0_fmt := $(if $(value 2),$2)
	)
	$(if $(value $0_fmt), \
		$(call dk_invoke,inspect,--format '$($0_fmt)',$($0_obj)), \
		$(call dk_invoke,inspect,,$($0_obj)) \
	)
)
endef

######################################################################################
# Helper Functions
######################################################################################

## dk_network_exists: Check if network exists
## Args:
##   1: network name (required)
## Returns: $(mb_true) if exists, $(mb_false) if not
define dk_network_exists
$(strip
	$(eval $0_network := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a network)))
	$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_on), \
		$(call dk_invoke,network inspect,,$($0_network)) \
		$(call mb_is_last_rc_ok) \
	)
)
endef

## dk_container_exists: Check if container exists
## Args:
##   1: container name/id (required)
## Returns: $(mb_true) if exists, $(mb_false) if not
define dk_container_exists
$(strip
	$(eval $0_container := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a container)))
	$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_on),\
		$(call dk_invoke,inspect,,$($0_container))\
		$(call mb_is_last_rc_ok)\
	)
)
endef

## dk_container_is_running: Check if container is running
## Args:
##   1: container name/id (required)
## Returns: $(mb_true) if running, $(mb_false) if not
define dk_container_is_running
$(strip
	$(eval $0_container := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a container)))
	$(eval $0_state := $(shell $(dk_bin) inspect -f '{{.State.Running}}' $($0_container) 2>/dev/null))
	$(if $(filter true,$($0_state)),$(mb_true),$(mb_false))
)
endef

## dk_container_ip: Get container IP address
## Args:
##   1: container name/id (required)
## Returns: IP address or empty string
define dk_container_ip
$(strip
	$(eval $0_container := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a container)))
	$(shell $(dk_bin) inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $($0_container) 2>/dev/null)
)
endef

## dk_image_exists: Check if image exists
## Args:
##   1: image name/id (required)
## Returns: $(mb_true) if exists, $(mb_false) if not
define dk_image_exists
$(strip
	$(eval $0_image := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass an image)))
	$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_on),\
		$(call dk_invoke,image inspect,,$($0_image))\
		$(call mb_is_last_rc_ok)\
	)
)
endef

## dk_volume_exists: Check if volume exists
## Args:
##   1: volume name (required)
## Returns: $(mb_true) if exists, $(mb_false) if not
define dk_volume_exists
$(strip
	$(eval $0_volume := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a volume)))
	$(let mb_invoke_silent mb_invoke_run_in_shell,$(mb_on) $(mb_on),\
		$(call dk_invoke,volume inspect,,$($0_volume))\
		$(call mb_is_last_rc_ok)\
	)
)
endef

## dk_stop_if_running: Stop container if it's running
## Args:
##   1: container name/id (required)
define dk_stop_if_running
$(strip
	$(eval $0_container := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a container)))
	$(if $(call dk_container_is_running,$($0_container)),\
		$(call mb_printf_info, Stopping container $($0_container))\
		$(call dk_invoke,stop,,$($0_container))\
	,\
		$(call mb_printf_info, Container $($0_container) is not running)\
	)
)
endef

## dk_remove_if_exists: Remove container if it exists
## Args:
##   1: container name/id (required)
##   2: force flag (optional, default: empty)
define dk_remove_if_exists
$(strip
	$(eval $0_container := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a container)))
	$(eval $0_force := $(if $(value 2),--force))
	$(if $(call dk_container_exists,$($0_container)),\
		$(call mb_printf_info, Removing container $($0_container))\
		$(call dk_invoke,rm,$($0_force),$($0_container))\
	,\
		$(call mb_printf_info, Container $($0_container) does not exist)\
	)
)
endef

######################################################################################
# Network Functions
######################################################################################

## @function dk_network_parse_params
## @desc Parse network target parameters from format: name[@driver][@subnet][@gateway]
## @desc Resolution order: target param > variable docker_network_<name>_<setting> > default
## @arg 1: params (required) - Params string, e.g., "mynet" or "mynet@overlay@172.20.0.0/16@172.20.0.1"
## @sets dk_network_parse_params_name - Network name
## @sets dk_network_parse_params_driver - Network driver (resolved)
## @sets dk_network_parse_params_subnet - Network subnet (resolved)
## @sets dk_network_parse_params_gateway - Network gateway (resolved)
## @example $(call dk_network_parse_params,mynet@overlay)
## @example Access: $(dk_network_parse_params_name), $(dk_network_parse_params_driver), etc.
define dk_network_parse_params
$(strip
	$(eval $0_arg1_params := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: params string required)))

	$(if $(findstring @,$($0_arg1_params)),\
		$(eval $0_parts := $(subst @, ,$($0_arg1_params)))\
		$(eval $0_name := $(word 1,$($0_parts)))\
		$(eval $0_param_driver := $(word 2,$($0_parts)))\
		$(eval $0_param_subnet := $(word 3,$($0_parts)))\
		$(eval $0_param_gateway := $(word 4,$($0_parts)))\
	,\
		$(eval $0_name := $($0_arg1_params))\
		$(eval $0_param_driver :=)\
		$(eval $0_param_subnet :=)\
		$(eval $0_param_gateway :=)\
	)

	$(eval $0_driver := $(strip \
		$(if $($0_param_driver),$($0_param_driver),\
			$(if $(value docker_network_$($0_name)_driver),$(docker_network_$($0_name)_driver),\
				$(dk_network_default_driver)))))

	$(eval $0_subnet := $(strip \
		$(if $($0_param_subnet),$($0_param_subnet),\
			$(if $(value docker_network_$($0_name)_subnet),$(docker_network_$($0_name)_subnet),))))

	$(eval $0_gateway := $(strip \
		$(if $($0_param_gateway),$($0_param_gateway),\
			$(if $(value docker_network_$($0_name)_gateway),$(docker_network_$($0_name)_gateway),))))
)
endef

## @function dk_network_create
## @desc Create a docker network with optional driver, subnet, and gateway
## @arg 1: name (required) - Network name
## @arg 2: driver (optional) - Network driver (default: bridge)
## @arg 3: subnet (optional) - Network subnet in CIDR notation, e.g., 172.20.0.0/16
## @arg 4: gateway (optional) - Network gateway IP, e.g., 172.20.0.1
define dk_network_create
$(strip
	$(eval $0_arg1_name := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: network name required)))
	$(eval $0_arg2_driver := $(if $(value 2),$(strip $2),bridge))
	$(eval $0_arg3_subnet := $(if $(value 3),$(strip $3)))
	$(eval $0_arg4_gateway := $(if $(value 4),$(strip $4)))

	$(eval $0_opts := --driver $($0_arg2_driver))
	$(if $($0_arg3_subnet),$(eval $0_opts += --subnet $($0_arg3_subnet)))
	$(if $($0_arg4_gateway),$(eval $0_opts += --gateway $($0_arg4_gateway)))

	$(call dk_invoke,network create,$($0_opts),$($0_arg1_name))
)
endef

## @function dk_network_remove
## @desc Remove a docker network
## @arg 1: name (required) - Network name to remove
define dk_network_remove
$(strip
	$(eval $0_arg1_name := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: network name required)))
	$(call dk_invoke,network rm,,$($0_arg1_name))
)
endef

######################################################################################
# mb_exec_with_mode handler
######################################################################################

## @function mb_exec_with_mode_docker
## @desc Execute command in a docker container using dk_shellc
## @desc This handler is called by mb_exec_with_mode when <prefix>_exec_mode is 'docker'
## @arg 1: command (required) - Command to execute in container
## @arg 2: prefix (required) - Variable prefix for config lookup
## @requires <prefix>_dk_container - Container name/id
## @optional <prefix>_dk_shell - Shell to use (default: dk_shell_default)
## @optional <prefix>_dk_tty - TTY flags (default: dk_exec_default_tty)
## @group exec_mode
## @see mb_exec_with_mode, dk_shellc
define mb_exec_with_mode_docker
$(strip
	$(eval $0_arg1_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: command argument required)))
	$(eval $0_arg2_prefix := $(if $(value 2),$(strip $2),$(call mb_printf_error,$0: prefix argument required)))

	$(eval $0_container := $(call mb_require_var,$($0_arg2_prefix)_dk_container,$0: $($0_arg2_prefix)_dk_container not defined for docker mode))
	$(eval $0_shell := $(if $(value $($0_arg2_prefix)_dk_shell),$($($0_arg2_prefix)_dk_shell),$(dk_shell_default)))
	$(eval $0_tty := $(if $(value $($0_arg2_prefix)_dk_tty),$($($0_arg2_prefix)_dk_tty),$(dk_exec_default_tty)))
	$(call dk_shellc,$($0_container),$($0_arg1_cmd),$($0_shell),$($0_tty))
)
endef
