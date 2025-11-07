ifndef __MB_MODULES_AWS__S3
__MB_MODULES_AWS__S3 := 1
# =============================================================================
# Helpers
# =============================================================================

aws_bucket_check ?= $(mb_off)# if $(mb_on), aws/s3/create/% checks if bucket exists before creating

define aws_s3_bucket_create
$(strip
	$(eval
		$0_aws_bucket := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: missing parameter 1 (bucket name)))
		$0_aws_check_bucket := $(if $(value 2),$(strip $2),$(aws_bucket_check))
		$0_execute := $(mb_true)
	)
	$(if $(filter $(mb_on),$($0_aws_check_bucket)),
		$(call mb_printf_info, Checking if bucket exists: $($0_aws_bucket))
		$(let mb_invoke_run_in_shell,$(mb_on),
			$(call mb_aws_invoke,s3api head-bucket --bucket "$($0_aws_bucket)")
		)
		$(if $(call mb_is_eq,0,$(mb_invoke_shell_exit_code)),
			$(call mb_printf_info, $(mb_check_mark) Bucket exists: $($0_aws_bucket))
			$(eval $0_execute := $(mb_false))
		),
	)
	$(if $(strip $($0_execute)),
		$(call mb_printf_info, Creating bucket: $($0_aws_bucket))
		$(call mb_aws_invoke,s3 mb s3://$($0_aws_bucket))
	)
)
endef
# =============================================================================
# S3 targets (essentials)
# All commands defer to $(call mb_aws_invoke,...) which injects global flags:
# --profile, --region, --endpoint-url, --output, --no-cli-pager, plus mb_aws_flags.
#
# Conventions:
# - Pattern targets use % => $*
# - Object/prefix targets read env vars (aws_bucket, aws_file, aws_dir, aws_dest, aws_expires),
#   and immediately copy to locals ($@_...) for formatting/validation.
# - Destructive actions require confirmation via mb_user_confirm.
# =============================================================================

.PHONY: aws/s3/list aws/s3/list/% aws/s3/list-recursive/% \
        aws/s3/create/% aws/s3/delete/% aws/s3/delete-force/% aws/s3/bucket-empty/% \
        aws/s3/put aws/s3/get aws/s3/object/head aws/s3/object/delete aws/s3/prefix/delete \
        aws/s3/sync-up aws/s3/sync-down aws/s3/presign

# ---- List buckets & objects --------------------------------------------------

aws/s3/list: ## List all S3 buckets
	$(call mb_aws_invoke,s3 ls)

aws/s3/list/%: ## List top-level objects in <bucket>
	$(eval $@_aws_bucket := $*)
	$(call mb_aws_invoke,s3 ls s3://$($@_aws_bucket)/)

aws/s3/list-recursive/%: ## List ALL objects in <bucket> (recursive, summarized)
	$(eval $@_aws_bucket := $*)
	$(call mb_aws_invoke,s3 ls s3://$($@_aws_bucket)/ --recursive --human-readable --summarize)

# ---- Create bucket -----------------------------------------------------------

aws/s3/create/%: ## Create buckets <bucket[/bucket2/...]> (respects aws_bucket_check)
	$(eval $@_aws_buckets := $(subst /, ,$*)) \
    $(foreach b,$($@_aws_buckets), \
    	$(call aws_s3_bucket_create,$b,$(aws_bucket_check)) \
    )

# ---- Delete / empty bucket (requires confirmation) ---------------------------

aws/s3/delete/%: ## Delete EMPTY <bucket> (fails if not empty) [requires confirmation]
	$(eval $@_aws_bucket := $*)
	$(if $(call mb_user_confirm,Delete EMPTY bucket s3://$($@_aws_bucket)?), \
		$(call mb_aws_invoke,s3 rb s3://$($@_aws_bucket)), \
		$(call mb_printf_warn,Aborted by user) \
	)

aws/s3/delete-force/%: ## Force-delete <bucket> (empties recursively) [requires confirmation]
	$(eval $@_aws_bucket := $*)
	$(if $(call mb_user_confirm,Force-delete bucket s3://$($@_aws_bucket) (empties all objects)?), \
		$(call mb_aws_invoke,s3 rb s3://$($@_aws_bucket) --force), \
		$(call mb_printf_warn,Aborted by user) \
	)

aws/s3/empty/%: ## Remove ALL objects under <bucket>/ (non-versioned) [requires confirmation]
	$(eval $@_aws_bucket := $*)
	$(if $(call mb_user_confirm,Remove ALL objects from s3://$($@_aws_bucket)/ ?), \
		$(call mb_aws_invoke,s3 rm s3://$($@_aws_bucket)/ --recursive), \
		$(call mb_printf_warn,Aborted by user) \
	)

aws/s3/key-delete/%: ## Delete ALL versions of ALL objects under <bucket>/ (versioned) [requires confirmation]
	$(eval $@_aws_bucket := $*)
	$(if $(call mb_user_confirm,Delete ALL versions of ALL objects from s3://$($@_aws_bucket)/ ?), \
		$(call mb_aws_invoke,s3api list-object-versions --bucket "$($@_aws_bucket)" --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' | jq -c '.Objects' | xargs -n 2 -I {} $(mb_aws_bin) s3api delete-objects --bucket "$($@_aws_bucket)" --delete '{}'), \
		$(call mb_printf_warn,Aborted by user) \
	)

# ---- Put / Get single objects (aws_bucket may include key) -------------------

aws/s3/put: ## Upload a file: aws_file=<file to upload> aws_bucket=<bucket[/prefix]> [aws_file_name_override=<name>]
	$(eval $@_aws_file   := $(call mb_require_value,aws_file,<local path>))
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket[/key]>))
	$(if $(wildcard $($@_aws_file)),,$(call mb_printf_error,File to upload not found: "$($@_aws_file)"))
	$(eval $@_fname_on_s3 := $(if $(value aws_file_name_override),
		$(aws_file_name_override)
	,
		$(notdir $($@_aws_file))
	))
# If caller gave only a bucket, default key to basename
	$(eval $@_s3_full_path := $($@_aws_bucket)/$($@_fname_on_s3))
	$(call mb_aws_invoke,s3 cp "$($@_aws_file)" s3://$($@_s3_full_path))

aws/s3/get: ## Download an object: aws_bucket=<bucket/key> [aws_dest=<dir-or-file> (default: .)]
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket/key>))
	$(eval $@_aws_dest   := $(if $(value aws_dest),$(aws_dest),.))
	$(call mb_aws_invoke,s3 cp s3://$($@_aws_bucket) "$($@_aws_dest)")

# Head-object needs bucket and key split; require aws_bucket as bucket/key
aws/s3/object/head: ## Show object metadata: aws_bucket=<bucket/key>
	$(eval $@_aws_bucket_path := $(call mb_require_value,aws_bucket,<bucket/key>))
	$(eval $@_bucket := $(firstword $(subst /, ,$($@_aws_bucket_path))))
	$(eval $@_has_key := $(findstring /,$($@_aws_bucket_path)))
	$(eval $@_key := $(if $($@_has_key),$(patsubst $($@_bucket)/%,%,$($@_aws_bucket_path)),))
	$(if $($@_key),,$(call mb_printf_error,aws_bucket must include a key for head-object: <bucket/key>))
	$(call mb_aws_invoke,s3api head-object --bucket "$($@_bucket)" --key "$($@_key)")

aws/s3/object/delete: ## Delete a single object: aws_bucket=<bucket/key> [requires confirmation]
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket/key>))
	$(if $(call mb_user_confirm,Delete s3://$($@_aws_bucket)?), \
		$(call mb_aws_invoke,s3 rm s3://$($@_aws_bucket)), \
		$(call mb_printf_warn,Aborted by user) \
	)

aws/s3/prefix/delete: ## Delete a prefix (folder): aws_bucket=<bucket/prefix/> [requires confirmation]
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket/prefix/>))
	$(if $(call mb_user_confirm,Delete ALL under s3://$($@_aws_bucket)?), \
		$(call mb_aws_invoke,s3 rm s3://$($@_aws_bucket) --recursive), \
		$(call mb_printf_warn,Aborted by user) \
	)

# ---- Directory sync (aws_bucket may include prefix) --------------------------

aws/s3/sync-up: ## Sync local dir => s3://bucket  aws_dir=<dir> aws_bucket=<bucket[/prefix]>
	$(eval $@_aws_dir    := $(call mb_require_value,aws_dir,<local path>))
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket[/prefix]>))
	$(call mb_aws_invoke,s3 sync "$($@_aws_dir)" "s3://$($@_aws_bucket)")

aws/s3/sync-down: ## Sync s3://aws_bucket => local aws_dir  aws_dir=<path> aws_bucket=<bucket[/prefix]>
	$(eval $@_aws_dir    := $(call mb_require_value,aws_dir,<local path>))
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket[/prefix]>))
	$(call mb_aws_invoke,s3 sync "s3://$($@_aws_bucket)" "$($@_aws_dir)")

# ---- Utilities ---------------------------------------------------------------

aws/s3/presign: ## Create a pre-signed URL: aws_bucket=<bucket/key> [aws_expires=<sec default:3600>]
	$(eval $@_aws_bucket := $(call mb_require_value,aws_bucket,<bucket/key>))
	$(eval $@_aws_expires := $(if $(value aws_expires),$(aws_expires),3600))
	$(call mb_aws_invoke,s3 presign s3://$($@_aws_bucket) --expires-in $($@_aws_expires))

endif # __MB_MODULES_AWS__S3