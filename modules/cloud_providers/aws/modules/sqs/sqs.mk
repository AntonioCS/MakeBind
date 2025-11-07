ifndef __MB_MODULES_AWS_SQS
__MB_MODULES_AWS_SQS := 1

# =============================================================================
# SQS targets (essentials)
# Uses $(call mb_aws_invoke,...) and MakeBind helpers.
#
# Env vars (examples):
#   aws_prefix                 -> optional filter for list (QueueNamePrefix)
#   aws_queue_url              -> full queue URL (preferred for most ops)
#   aws_message                -> message body for send
#   aws_message_group_id       -> FIFO group id (optional)
#   aws_message_dedup_id       -> FIFO dedup id (optional)
#   aws_max_messages           -> receive max (1..10) (optional)
#   aws_wait_time              -> long poll seconds (0..20) (optional)
#   aws_visibility_timeout     -> seconds to hide received messages (optional)
#   aws_receipt_handle         -> handle returned by receive (for delete-message)
#   aws_attribute_names        -> e.g., All or comma/space separated names (for attributes)
#   aws_attributes_json        -> JSON for create/set-attributes
# =============================================================================

.PHONY: aws/sqs/list aws/sqs/create/% aws/sqs/url/% \
        aws/sqs/send aws/sqs/receive aws/sqs/delete-message \
        aws/sqs/purge aws/sqs/delete \
        aws/sqs/attributes aws/sqs/set-attributes

aws_sqs_get_queue_url_cache_ttl ?= 3600 # Cache for 1 hour

# $1 - Queue name
# $2 - Silent on/off
define aws_sqs_get_queue_url
$(strip
	$(eval
		$0_queue_name := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 requires a queue name))
		$0_silent := $(strip $(if $(value 2),$2,$(mb_on)))
	)
	$(eval $0_cache_key := $0_$($0_queue_name))
	$(if $(call mb_cache_has,$($0_cache_key)),
		$(call mb_cache_read,$($0_cache_key),$0_cache_result)
		$($0_cache_result)
	,
		$(let mb_invoke_silent mb_invoke_run_in_shell,$($0_silent) $(mb_on),
			$(call mb_aws_invoke,sqs get-queue-url --queue-name "$($0_queue_name)" --query QueueUrl --output text)
		)
		$(if $(call mb_is_last_rc_ok),
			$(call mb_cache_write,$($0_cache_key),$(mb_invoke_shell_output),$(aws_sqs_get_queue_url_cache_ttl))
			$(mb_invoke_shell_output)
		)
	)
)
endef

define aws_if_queue_name_give_url
$(strip
	$(if $(call mb_is_url,$*),
		$*
	,
		$(call aws_sqs_get_queue_url,$*)
	)
)
endef

# ---- List & basic discovery --------------------------------------------------

aws/sqs/list: ## List queues [optional: aws_prefix=<name-prefix>]
	$(eval $@_opt := $(if $(value aws_prefix),--queue-name-prefix $(aws_prefix),))
	$(call mb_aws_invoke,sqs list-queues $($@_opt))

aws/sqs/url/%: ## Get queue URL for <queue-name>
	$(eval $@_name := $*)
	$(eval $@_result := $(call aws_sqs_get_queue_url,$($@_name),$(mb_off)))
	$(if $($@_result),\
		$(info $($@_result))\
	,\
		$(call mb_printf_error,Invalid queue - $($@_name))\
	)

#$(call mb_aws_invoke,sqs get-queue-url --queue-name "$($@_name)" --query QueueUrl --output text))
# ---- Create / Delete / Purge -------------------------------------------------

aws/sqs/create/%: ## Create queue <queue-name> [optional: aws_attributes_json='{"FifoQueue":"true",...}']
	$(eval
		$@_name := $*
		$@_attrs := $(if $(value aws_attributes_json),--attributes '$(aws_attributes_json)',)
	)
	$(call mb_aws_invoke,sqs create-queue --queue-name "$($@_name)" $($@_attrs))

aws/sqs/delete/%: ## Delete queue <queue name|url> [requires confirmation]
	$(eval $@_url = $(call aws_if_queue_name_give_url,$*))
	$(if $(call mb_user_confirm,Delete queue $($@_url)?), \
		$(call mb_aws_invoke,sqs delete-queue --queue-url "$($@_url)")\
		$(call mb_printf_info, Queue deleted)\
	, \
		$(call mb_printf_warn,Aborted by user) \
	)

aws/sqs/purge/%: ## Purge ALL messages from <queue name|url> [requires confirmation]: aws_queue_url=<url>
	$(eval $@_url = $(call aws_if_queue_name_give_url,$*))
	$(if $(call mb_user_confirm,Purge ALL messages from $($@_url)?), \
		$(call mb_aws_invoke,sqs purge-queue --queue-url "$($@_url)")\
		$(call mb_printf_info, Queue purged)\
	, \
		$(call mb_printf_warn,Aborted by user) \
	)

# ---- Send / Receive / Delete message ----------------------------------------

aws/sqs/send: ## Send message: aws_queue_url=<url> aws_message=<body> [aws_message_group_id=...] [aws_message_dedup_id=...]
	$(call mb_require_into,$@_url,aws_queue_url,<queue URL>)
	$(call mb_require_into,$@_body,aws_message,<message body>)
	# Optional FIFO bits
	$(eval $@_opt_gid  := $(if $(value aws_message_group_id),--message-group-id '$(aws_message_group_id)',))
	$(eval $@_opt_ddup := $(if $(value aws_message_dedup_id),--message-deduplication-id '$(aws_message_dedup_id)',))
	$(call mb_aws_invoke,sqs send-message --queue-url "$($@_url)" --message-body '$(strip $($@_body))' $($@_opt_gid) $($@_opt_ddup))

aws/sqs/receive: ## Receive messages: aws_queue_url=<url> [aws_max_messages=1..10] [aws_wait_time=0..20] [aws_visibility_timeout=...]
	$(call mb_require_into,$@_url,aws_queue_url,<queue URL>)
	$(eval $@_opt_max := $(if $(value aws_max_messages),--max-number-of-messages $(aws_max_messages),))
	$(eval $@_opt_wait := $(if $(value aws_wait_time),--wait-time-seconds $(aws_wait_time),))
	$(eval $@_opt_vis  := $(if $(value aws_visibility_timeout),--visibility-timeout $(aws_visibility_timeout),))
	$(call mb_aws_invoke,sqs receive-message --queue-url "$($@_url)" $($@_opt_max) $($@_opt_wait) $($@_opt_vis) --attribute-names All --message-attribute-names All)

aws/sqs/delete-message: ## Delete a single message: aws_queue_url=<url> aws_receipt_handle=<handle>
	$(call mb_require_into,$@_url,aws_queue_url,<queue URL>)
	$(call mb_require_into,$@_rh,aws_receipt_handle,<receipt handle>)
	$(call mb_aws_invoke,sqs delete-message --queue-url "$($@_url)" --receipt-handle '$(strip $($@_rh))')



#NOTE: Use a function to call aws/sqs/url
aws/sqs/peek/%: ## Peek messages from queue <queue-name>
	$(eval $@_url = $(call aws_if_queue_name_give_url,$*))
	$(call mb_aws_invoke, \
		sqs receive-message \
			--queue-url "$($@_url)" \
			--max-number-of-messages 10 \
			--visibility-timeout 0 \
			--attribute-names All \
			--message-attribute-names All | jq . \
	)


# ---- Queue attributes --------------------------------------------------------

aws/sqs/attributes: ## Get attributes: aws_queue_url=<url> [aws_attribute_names=All|<names>]
	$(call mb_require_into,$@_url,aws_queue_url,<queue URL>)
	$(eval $@_names := $(if $(value aws_attribute_names),$(aws_attribute_names),All))
	$(call mb_aws_invoke,sqs get-queue-attributes --queue-url "$($@_url)" --attribute-names $($@_names))

aws/sqs/set-attributes: ## Set attributes: aws_queue_url=<url> aws_attributes_json='{"Key":"Value",...}'
	$(call mb_require_into,$@_url,aws_queue_url,<queue URL>)
	$(call mb_require_into,$@_attrs_json,aws_attributes_json,<json map>)
	$(call mb_aws_invoke,sqs set-queue-attributes --queue-url "$($@_url)" --attributes '$(strip $($@_attrs_json))')




endif # __MB_MODULES_AWS_SQS