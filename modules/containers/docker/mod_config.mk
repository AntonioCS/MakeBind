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
