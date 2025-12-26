#####################################################################################
# Project: MakeBind
# File: modules/containers/docker/mod_config.mk
# Description: Configuration for docker module
# Author: AntonioCS
# License: MIT License
#####################################################################################

## Toggle debug for Docker-related targets (inherits global mb_debug by default)
mb_debug_dk_invoke ?= $(mb_debug)#

## Docker CLI binary
dk_bin ?= docker#

## Global CLI flags for docker commands (e.g., -H tcp://..., --context myctx)
dk_bin_options ?=#

## Default shell when exec-ing into containers
dk_shell_default ?= /bin/sh#

## Default TTY/interactive flags for `docker exec`
dk_exec_default_tty ?= -it#

## Default options for docker logs (non-blocking by default)
dk_logs_default_opts ?= --tail=200#

## Default network driver for docker/network/create and docker/network/ensure targets
dk_network_default_driver ?= bridge#

## Suppress errors for network create (when exists) and remove (when missing)
## Set to 'true' to skip silently instead of failing
docker_network_ignore_errors ?=#

## Default command for running commands in containers
dk_exec_default_dk_cmd ?= exec