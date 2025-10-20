## Toggle debug for Symfony-related targets (inherits global mb_debug by default)
mb_debug_php_sy ?= $(mb_debug)

## Path to Symfony console binary
php_sy_bin ?= bin/console

## Path to Symfony logs directory
php_sy_logs_path ?= $(mb_project_path)/var/log

## Runtime environment: dev|test|prod
php_sy_env ?= dev

## If true, read APP_ENV from .env files
php_sy_read_env_files ?= $(mb_true)

## Base .env to read (will also try .env.$(php_sy_env) and .env.local)
php_sy_read_env_files_default_file ?= $(mb_project_path)/.env

## If true, loads doctrine submodule targets
php_sy_doctrine_enable ?= $(mb_true)

## If true, pass -v to console commands
php_sy_verbose ?= $(mb_false)

## If true, pipe tail to jq using the formatter below
php_sy_logs_use_jq_in_tail ?= $(mb_false)

## Path to helpers folder (jq formatters, etc.)
php_sy_helpers_path ?= $(php_sy_mod_path)/helpers

## jq formatter for Symfony logs
php_sy_jq_log_formatters ?= $(php_sy_helpers_path)/jq/log_format.jq
