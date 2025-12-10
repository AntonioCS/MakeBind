#####################################################################################
# Project: MakeBind
# File: modules/containers/docker/docker.mk
# Description: Docker container management targets and utilities
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER__
__MB_MODULES_DOCKER__ := 1

__mb_docker_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__mb_docker_dir)functions.mk
include $(__mb_docker_dir)targets.mk

endif # __MB_MODULES_DOCKER__
