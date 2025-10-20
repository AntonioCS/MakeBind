
## Use docker for php commands (This will require docker_compose module)
php_use_docker ?= $(if $(value dc_invoke),$(mb_true))#

## Docker compose service name for php container (only needed if php_use_docker is true)
php_dc_service ?=#

##  Default shell to use in php container
php_dc_default_shell ?= $(if $(value dc_default_shell_bin),$(dc_default_shell_bin))#

## PHP binary path (local or in container)
php_bin ?= /usr/local/bin/php

## Mode to invoke docker commands (exec or run), defaults to exec
php_invoke_dc_mode ?= exec#

## Mode to invoke docker shell commands (exec or run), defaults to php_invoke_dc_mode
## This is the way it uses to shell into the container
php_dc_shell_mode ?= $(php_invoke_dc_mode)#

######################################################
## Check if xdebug listener is on, if not disable xdebug for php commands (use $(mb_on) or $(mb_off))
php_xdebug_check_listener ?= $(mb_on)#
php_xdebug_listener_host ?= 127.0.0.1#
php_xdebug_listener_port ?= 9003#

######################################################
## Path to PHPStan binary
phpstan_bin ?= vendor/bin/phpstan#

## PHPStan config file (relative to project root)
phpstan_config_file ?= phpstan.neon#

## If true, redirect PHPStan output to a file
phpstan_send_to_file ?= $(mb_true)#

## PHPStan output file path
phpstan_output_file ?= phpstan.output#

######################################################
## Path to Psalm binary
psalm_bin ?= vendor/bin/psalm#

## If true, redirect Psalm output to a file
psalm_send_to_file ?= $(mb_true)#

## Psalm output file path
psalm_output_file ?= psalm.output#

## Extra flags for Psalm (e.g., -m for monolithic, compact output)
psalm_flags ?= -m --output-format=compact#
