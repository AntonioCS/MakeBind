#####################################################################################
# LocalStack Module Configuration
#####################################################################################

## @var localstack_region
## @desc AWS region for LocalStack operations
## @type string
## @default eu-west-1
## @group localstack
localstack_region ?= eu-west-1

## @var localstack_account_id
## @desc AWS account ID (LocalStack default)
## @type string
## @default 000000000000
## @group localstack
localstack_account_id ?= 000000000000

## @var localstack_endpoint_url
## @desc LocalStack API endpoint URL
## @type string
## @default http://localhost:4566
## @values http://localhost:4566, http://localstack:4566, custom URLs
## @group localstack
## @example localstack_endpoint_url=http://localstack:4566 make localstack/health
localstack_endpoint_url ?= http://localhost:4566

#####################################################################################
# Execution Mode Configuration (mb_exec_with_mode)
#####################################################################################

## @var localstack_exec_mode
## @desc Execution mode for LocalStack CLI commands
## @type string
## @default local
## @values local, docker, docker-compose
## @group localstack
## @example localstack_exec_mode=docker make localstack/version
## @see mb_exec_with_mode
localstack_exec_mode ?= local

## @var localstack_bin
## @desc Path to localstack CLI binary (for local mode)
## @type string
## @default localstack
## @group localstack
localstack_bin ?= localstack

## @var localstack_dk_container
## @desc Container name for docker mode execution and shell access
## @type string
## @default localstack
## @group localstack
## @see localstack_exec_mode
localstack_dk_container ?= localstack

## @var localstack_dk_shell
## @desc Shell to use in docker mode
## @type string
## @default /bin/bash
## @group localstack
localstack_dk_shell ?= /bin/bash

## @var localstack_dc_service
## @desc Docker-compose service name for docker-compose mode
## @type string
## @default localstack
## @group localstack
## @see localstack_exec_mode
localstack_dc_service ?= localstack

## @var localstack_dc_shell
## @desc Shell to use in docker-compose mode
## @type string
## @default /bin/bash
## @group localstack
localstack_dc_shell ?= /bin/bash
