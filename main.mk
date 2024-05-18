#####################################################################################
# Project: MakeBind
# File: main.mk
# Description: Main entry point for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
mb_make_version_required ?= 4.4%

ifndef CI
ifeq ($(filter $(mb_make_version_required),$(MAKE_VERSION)),)
    $(error Incompatible GNU Make version, please upgrade to $(subst %,*,$(mb_make_version_required)) or higher)
endif
endif

mb_debug ?= 0
mb_default_shell ?= /bin/bash

.ONESHELL:
SHELL := $(mb_default_shell)

MAKEFLAGS := --no-builtin-rules \
			--no-builtin-variables \
			--always-make \ # Always consider the target out of date
			--warn-undefined-variables \
			--no-print-directory \ # Disable printing of the working directory by invoked sub-makes (the well-known “Entering/Leaving directory ...” messages)
			$(if $(mb_debug),,--silent)

# Configure shell flags:
# '-e' exits the shell if any command exits with a non-zero status.
# '-u' treats unset variables and parameters as an error when performing parameter expansion.
# '-c' tells the shell that the commands to run are coming from the string argument following this option.
# '-x' (conditionally included if MB_DEBUG is set) prints each command before execution, useful for debugging.
# '-o pipefail' ensures the pipeline's return status is the exit code of the last command to exit with a non-zero status.
.SHELLFLAGS := -euc$(if $(mb_debug),x)o pipefail

.DEFAULT_GOAL := targets-list
