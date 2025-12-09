#####################################################################################
# LocalStack Module Configuration
#####################################################################################

## @var localstack_container_name
## @desc LocalStack container name for shell access and health checks
## @desc Container may be in external docker-compose project (e.g., dockyard)
## @type string
## @default dy-localstack
## @group localstack
## @example localstack_container_name=my-localstack make localstack/shell
## @see localstack_endpoint_url
localstack_container_name ?= localstack

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
## @see localstack_container_name
localstack_endpoint_url ?= http://localhost:4566

## @var localstack_shell
## @desc Shell to use when accessing LocalStack container
## @type string
## @default bash
## @values bash, sh, zsh
## @group localstack
localstack_shell ?= bash
