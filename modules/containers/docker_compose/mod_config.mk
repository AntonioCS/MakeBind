
### Files to use with docker compose, space separated
dc_files ?=#
### Env files to use with docker compose, space separated
dc_env_files ?=#
### Binary to use for docker compose
dc_bin ?= docker compose#
### Options to use with docker compose binary
dc_bin_options ?= $(if $(value mb_project_name),-p $(mb_project_name))
### Default shell binary to use in containers
dc_default_shell_bin ?= /bin/sh
### Use buildkit when building images with docker compose (use $(mb_true) or $(mb_false)) WIP
dc_use_bake ?= $(mb_true)#

## dc_shellc function options
dc_shellc_default_shell_bin ?= $(dc_default_shell_bin) # or /bin/bash
dc_shellc_default_cmd ?= exec # or run

### Options variables for dc_invoke function (function used to run docker compose commands)
### Variables that will affect the specific command
## dc_cmd_options_<command> = Command specific options
## dc_cmd_services_<command> = Command specific service(s)
## dc_cmd_extras_<command> = Command specific extras

