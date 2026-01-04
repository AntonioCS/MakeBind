## PostgreSQL Module Configuration
## ================================

## Enabled features (space-separated list)
## Available: core sql db role conn session dump extension table index maintenance
pg_features ?= core sql db dump maintenance#

#####################################################################################
## Execution Mode Configuration (mb_exec_with_mode compatible)
#####################################################################################

## Execution mode: local, docker, docker-compose
pg_exec_mode ?= local#

## Docker mode settings
pg_dk_container ?= postgres#
pg_dk_shell ?= /bin/bash#

## Docker Compose mode settings
pg_dc_service ?= postgres#
pg_dc_shell ?= /bin/bash#

#####################################################################################
## Connection Settings
#####################################################################################

pg_user ?= postgres#
pg_pass ?=#
pg_db ?= app#

## Host/port for local mode connections
pg_host ?= 127.0.0.1#
pg_port ?= 5432#

#####################################################################################
## Dump & Restore Settings
#####################################################################################

pg_dump_dir ?= backups#
pg_dump_format ?= c#
pg_dump_flags ?= --no-owner --no-privileges#
pg_restore_flags ?= --clean --if-exists --no-owner --no-privileges#

#####################################################################################
## Session Management Settings
#####################################################################################

pg_idle_timeout ?= 30#
pg_long_query_threshold ?= 60#
