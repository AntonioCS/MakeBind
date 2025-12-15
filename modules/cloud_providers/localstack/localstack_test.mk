#####################################################################################
# Project: MakeBind
# File: modules/cloud_providers/localstack/localstack_test.mk
# Description: Tests for the localstack module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load AWS module dependencies (localstack wraps AWS module)
include $(mb_modules_path)/cloud_providers/aws/mod_config.mk
include $(mb_modules_path)/cloud_providers/aws/aws.mk

## Load localstack module
include $(mb_modules_path)/cloud_providers/localstack/mod_config.mk
include $(mb_modules_path)/cloud_providers/localstack/localstack.mk

######################################################################################
# localstack_cmd tests
######################################################################################

define test_modules_localstack_cmd_basic
	$(eval mb_invoke_silent := $(mb_on))

	## Test basic S3 command
	$(eval $0_result := $(call localstack_cmd,s3 ls))
	$(call mb_assert_contains,s3 ls,$($0_result),localstack_cmd should contain s3 ls)
	$(call mb_assert_contains,--endpoint-url,$($0_result),localstack_cmd should contain endpoint-url)
	$(call mb_assert_contains,$(localstack_endpoint_url),$($0_result),localstack_cmd should contain localstack endpoint)

	## Test SQS command
	$(eval $0_result := $(call localstack_cmd,sqs list-queues))
	$(call mb_assert_contains,sqs list-queues,$($0_result),localstack_cmd should contain sqs list-queues)
	$(call mb_assert_contains,--endpoint-url,$($0_result),localstack_cmd should contain endpoint-url)

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_localstack_cmd_with_bucket_param
	$(eval mb_invoke_silent := $(mb_on))

	## Test S3 ls with bucket path
	$(eval $0_result := $(call localstack_cmd,s3 ls s3://my-bucket))
	$(call mb_assert_contains,s3 ls s3://my-bucket,$($0_result),localstack_cmd should contain bucket path)

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_localstack_cmd_error_without_args
	$(eval mb_invoke_silent := $(mb_on))

	## Test that localstack_cmd requires an argument
	## Note: This test validates the error path - mb_printf_error will be called
	$(call mb_assert_was_called,mb_printf_error,1)
	$(eval $0_result := $(call localstack_cmd,))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# localstack_api tests
######################################################################################

define test_modules_localstack_api_basic
	$(eval mb_invoke_silent := $(mb_on))

	## Test that localstack_api sets up the correct URL
	## Note: We can't actually call the API in tests, but we can verify the function exists
	$(call mb_assert,$(value localstack_api),localstack_api function should be defined)

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_localstack_api_error_without_endpoint
	$(eval mb_invoke_silent := $(mb_on))

	## Test that localstack_api requires an endpoint argument
	$(call mb_assert_was_called,mb_printf_error,1)
	$(eval $0_result := $(call localstack_api,))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# localstack_api_check tests
######################################################################################

define test_modules_localstack_api_check_error_without_endpoint
	$(eval mb_invoke_silent := $(mb_on))

	## Test that localstack_api_check requires an endpoint argument
	## Note: Expects 3 calls due to cascading errors:
	##   1. localstack_api_check: endpoint required
	##   2. localstack_api: endpoint path required (called internally)
	##   3. localstack_api_check: error_msg (api call failed)
	$(call mb_assert_was_called,mb_printf_error,3)
	$(eval $0_result := $(call localstack_api_check,))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# localstack_api_json tests
######################################################################################

define test_modules_localstack_api_json_error_without_endpoint
	$(eval mb_invoke_silent := $(mb_on))

	## Test that localstack_api_json requires an endpoint argument
	$(call mb_assert_was_called,mb_printf_error,1)
	$(eval $0_result := $(call localstack_api_json,))

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# Configuration tests
######################################################################################

define test_modules_localstack_config_defaults
	$(call mb_assert_eq,eu-west-1,$(localstack_region),localstack_region should default to eu-west-1)
	$(call mb_assert_eq,000000000000,$(localstack_account_id),localstack_account_id should default to 000000000000)
	$(call mb_assert_eq,http://localhost:4566,$(localstack_endpoint_url),localstack_endpoint_url should default to http://localhost:4566)
	$(call mb_assert_eq,local,$(localstack_exec_mode),localstack_exec_mode should default to local)
	$(call mb_assert_eq,localstack,$(localstack_dk_container),localstack_dk_container should default to localstack)
	$(call mb_assert_eq,localstack,$(localstack_dc_service),localstack_dc_service should default to localstack)
endef

######################################################################################
# Convenience target command generation tests
######################################################################################

define test_modules_localstack_s3_ls_command
	$(eval mb_invoke_silent := $(mb_on))

	## Test S3 ls generates correct command (without bucket)
	$(eval $0_result := $(call localstack_cmd,s3 ls))
	$(call mb_assert_contains,s3 ls,$($0_result),localstack/s3/ls should generate s3 ls command)
	$(call mb_assert_contains,--endpoint-url $(localstack_endpoint_url),$($0_result),should include endpoint URL)

	## Test S3 ls with bucket parameter
	$(eval bucket := test-bucket)
	$(eval $0_result := $(call localstack_cmd,s3 ls $(if $(value bucket),s3://$(bucket),)))
	$(call mb_assert_contains,s3 ls s3://test-bucket,$($0_result),localstack/s3/ls with bucket should include bucket path)
	$(eval undefine bucket)

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_localstack_sqs_ls_command
	$(eval mb_invoke_silent := $(mb_on))

	## Test SQS ls generates correct command
	$(eval $0_result := $(call localstack_cmd,sqs list-queues))
	$(call mb_assert_contains,sqs list-queues,$($0_result),localstack/sqs/ls should generate sqs list-queues command)
	$(call mb_assert_contains,--endpoint-url $(localstack_endpoint_url),$($0_result),should include endpoint URL)

	$(eval mb_invoke_silent := $(mb_off))
endef

######################################################################################
# Function definition tests
######################################################################################

define test_modules_localstack_functions_defined
	$(call mb_assert,$(value localstack_cmd),localstack_cmd function should be defined)
	$(call mb_assert,$(value localstack_api),localstack_api function should be defined)
	$(call mb_assert,$(value localstack_api_check),localstack_api_check function should be defined)
	$(call mb_assert,$(value localstack_api_json),localstack_api_json function should be defined)
endef
