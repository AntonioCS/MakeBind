#####################################################################################
# LocalStack Module
# AWS Service Emulation Wrapper for Local Development
#
# Version: 2.0.0
# Author: AntonioCS
# License: MIT
#####################################################################################
# Overview:
#   Thin wrapper around the AWS module that redirects operations to LocalStack.
#   Uses host-based AWS CLI to support external docker-compose projects.
#
# Prerequisites:
#   - LocalStack running and accessible
#   - aws CLI on host with network access to LocalStack endpoint
#   - jq (for JSON parsing in status commands)
#   - Module dependencies defined in mod_info.mk
#
# Key Pattern:
#   make localstack/aws/<target> → Redirects to aws/<target> with LocalStack endpoint
#
#####################################################################################

ifndef __MB_MODULES_LOCALSTACK__
__MB_MODULES_LOCALSTACK__ := 1

#####################################################################################
# Helper Functions
#####################################################################################

## @function localstack_cmd
## @desc Execute AWS CLI command against LocalStack endpoint
## @desc Thin wrapper around mb_aws_invoke that automatically sets LocalStack endpoint and region
## @arg 1: command (required) - AWS subcommand and arguments (e.g., "s3 ls", "sqs list-queues")
## @returns Command output via mb_aws_invoke
## @group localstack
## @example $(call localstack_cmd,s3 ls)
## @example $(call localstack_cmd,sqs create-queue --queue-name test)
## @see mb_aws_invoke, localstack_endpoint_url, localstack_region
define localstack_cmd
$(strip \
	$(if $(value 1),,$(call mb_printf_error,$0: command argument required)) \
	$(let aws_endpoint aws_region, $(localstack_endpoint_url) $(localstack_region), \
		$(call mb_aws_invoke,$1) \
	) \
)
endef

## @function localstack_api
## @desc Low-level HTTP API caller for LocalStack endpoints with error capture
## @desc Makes HTTP request to LocalStack API and captures both exit code and output
## @desc for composability. This is the foundation for higher-level API functions.
## @arg 1: endpoint_path (required) - API endpoint path (e.g., "/_localstack/health")
## @arg 2: curl_flags (optional) - curl flags to use (default: "-s" for silent)
## @returns Sets two variables: localstack_api_exit_code (numeric, 0=success) and localstack_api_output (response body)
## @group localstack
## @example $(call localstack_api,/_localstack/health,-sf)
## @example $(call localstack_api,/_localstack/init)
## @see localstack_api_check, localstack_api_json, localstack_endpoint_url
define localstack_api
$(strip \
	$(if $(value 1),,$(call mb_printf_error,localstack_api: endpoint path required)) \
	$(eval $0_endpoint := $(strip $1)) \
	$(eval $0_flags := $(strip $(if $(value 2),$2,-s))) \
	$(eval $0_url := $(localstack_endpoint_url)$($0_endpoint)) \
	$(call mb_shell_capture,curl $($0_flags) $($0_url) 2>/dev/null,localstack_api_exit_code,localstack_api_output) \
)
endef

## @function localstack_api_check
## @desc High-level health check wrapper with automatic error handling
## @desc Calls localstack_api and either prints success message or stops execution
## @desc with error message. Does not return a value to prevent shell execution issues.
## @arg 1: endpoint (required) - API endpoint path to check (e.g., "/_localstack/health")
## @arg 2: success_msg (optional) - Message to print on success (default: "LocalStack API responded successfully")
## @arg 3: error_msg (optional) - Message to print on failure (default: "LocalStack not responding at <endpoint_url>")
## @returns Does not return a value (prints message and either continues or stops execution)
## @group localstack
## @example $(call localstack_api_check,/_localstack/health)
## @example $(call localstack_api_check,/endpoint,All good!,Oh no!)
## @see localstack_api, mb_printf_info, mb_printf_error
define localstack_api_check
$(strip \
	$(if $(value 1),,$(call mb_printf_error,localstack_api_check: endpoint required)) \
	$(eval $0_endpoint := $(strip $1)) \
	$(eval $0_success_msg := $(strip $(if $(value 2),$2,LocalStack API responded successfully))) \
	$(eval $0_error_msg := $(strip $(if $(value 3),$3,LocalStack not responding at $(localstack_endpoint_url)))) \
	$(call localstack_api,$($0_endpoint),-sf) \
	$(if $(filter 0,$(localstack_api_exit_code)), \
		$(call mb_printf_info,$($0_success_msg)), \
		$(call mb_printf_error,$($0_error_msg)) \
	) \
)
endef

## @function localstack_api_json
## @desc Fetch and format JSON responses from LocalStack API with jq filtering
## @desc The jq filter is automatically quoted to prevent shell interpretation of
## @desc special characters like pipes. Supports defensive jq patterns with // operator.
## @arg 1: endpoint (required) - API endpoint path (e.g., "/_localstack/init")
## @arg 2: jq_filter (optional) - jq filter expression (default: "." for pretty-print entire response)
## @returns Formatted JSON output via mb_invoke
## @group localstack
## @example $(call localstack_api_json,/_localstack/init)
## @example $(call localstack_api_json,/_localstack/init,.completed)
## @example $(call localstack_api_json,/_localstack/init,.services // {} | keys)
## @see localstack_api, localstack_endpoint_url
define localstack_api_json
$(strip \
	$(if $(value 1),,$(call mb_printf_error,localstack_api_json: endpoint required)) \
	$(eval $0_endpoint := $(strip $1)) \
	$(eval $0_jq_filter := $(strip $(if $(value 2),$2,.))) \
	$(eval $0_cmd := curl -s $(localstack_endpoint_url)$($0_endpoint) | jq '$($0_jq_filter)') \
	$(call mb_invoke,$($0_cmd)) \
)
endef

#####################################################################################
# LocalStack-Specific Targets
#####################################################################################

.PHONY: localstack/health localstack/status localstack/shell localstack/validate localstack/diagnostics
.PHONY: localstack/s3/list-all localstack/sqs/purge-all

localstack/health: ## Check if LocalStack is running and healthy
	$(call localstack_api_check,/_localstack/health,LocalStack is healthy at $(localstack_endpoint_url))

localstack/status: ## Show LocalStack initialization status
	$(call localstack_api_json,/_localstack/init)

localstack/shell: ## Open shell in LocalStack container (external container)
	$(call dk_invoke,exec,-it,$(localstack_container_name),$(localstack_shell))

localstack/validate: ## Validate LocalStack configuration
	$(if $(value localstack_container_name),,$(call mb_printf_error,localstack_container_name not set))
	$(if $(value localstack_endpoint_url),,$(call mb_printf_error,localstack_endpoint_url not set))
	$(call mb_printf_info,LocalStack configuration valid)

localstack/diagnostics: ## Run comprehensive LocalStack diagnostics
	$(call mb_printf_info,=== LocalStack Diagnostics ===)
	$(call mb_printf_info,Endpoint: $(localstack_endpoint_url))
	$(call mb_printf_info,Container: $(localstack_container_name))
	echo ""
	$(call mb_printf_info,--- Health Check ---)
	$(call localstack_api_check,/_localstack/health)
	echo ""
	$(call mb_printf_info,--- Initialization Status ---)
	$(call localstack_api_json,/_localstack/init,.completed)
	echo ""
	$(call mb_printf_info,--- Running Services ---)
	$(call localstack_api_json,/_localstack/init,.services // {} | keys)
	echo ""
	$(call mb_printf_info,=== Diagnostics Complete ===)

#####################################################################################
# Convenience Targets (Common Operations)
#####################################################################################

localstack/s3/list-all: ## List all S3 buckets with details
	$(call localstack_cmd,s3 ls)
	echo ""
	$(call mb_printf_info,Listing contents of all buckets:)
	$(let mb_invoke_run_in_shell,$(mb_on),\
		$(call localstack_cmd,s3api list-buckets --query "Buckets[].Name" --output text)\
	)
	$(eval _buckets := $(mb_invoke_shell_output))
	$(if $(strip $(_buckets)),\
		$(foreach b,$(strip $(_buckets)),\
			echo "";\
			$(call mb_printf_info,Bucket: $(b));\
			$(call localstack_cmd,s3 ls s3://$(b) --recursive) || echo "  (empty)";\
		),\
		$(call mb_printf_warn,No buckets found)\
	)

localstack/sqs/purge-all: ## Purge all SQS queues (use with caution!)
	$(call mb_printf_warn,Purging all SQS queues...)
	$(let mb_invoke_run_in_shell,$(mb_on),\
		$(call localstack_cmd,sqs list-queues --query "QueueUrls[]" --output text)\
	)
	$(eval _queue_urls := $(mb_invoke_shell_output))
	$(if $(strip $(_queue_urls)),\
		$(foreach url,$(strip $(_queue_urls)),\
			$(call mb_printf_info,Purging: $(url));\
			$(call localstack_cmd,sqs purge-queue --queue-url $(url)) || true;\
		),\
		$(call mb_printf_warn,No queues found)\
	)

#####################################################################################
# AWS Module Integration - The Magic Redirect
#
# This pattern redirects ALL aws module targets to LocalStack by setting the
# aws_endpoint variable. This avoids duplicating S3/SQS/SNS functionality.
#
# Examples:
#   make localstack/aws/s3/create/my-bucket
#   make localstack/aws/sqs/create/my-queue
#   make localstack/aws/sqs/purge/my-queue
#
# Note: The semicolon (;) provides an empty recipe, telling Make "don't search for
# implicit rules - just set the variable and delegate to the prerequisite."
# Without it, Make may fail or apply incorrect implicit rules.
# See: https://www.gnu.org/software/make/manual/html_node/Empty-Recipes.html
#####################################################################################

localstack/aws/%: ## Redirect to aws module with LocalStack endpoint (e.g., localstack/aws/s3/create/bucket-name)
localstack/aws/%: aws_endpoint := $(localstack_endpoint_url)
localstack/aws/%: aws/% ;

localstack/aws: # Wrapper for localstack/aws/%
	$(call mb_printf_info,Usage: make localstack/aws/<aws_target> (e.g.$(mb_comma) localstack/aws/s3/create/my-bucket))

endif # __MB_MODULES_LOCALSTACK__
