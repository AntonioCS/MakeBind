#####################################################################################
# Project:
# File:
# Description:
# Author:
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_AWS__
__MB_MODULES_AWS__ := 1


# -------------------------------------------------------------------
# AWS CLI invoker
# Usage:
#   $(call mb_aws_invoke,<service & command...>[,<extra flags>])
#
# Examples:
#   $(call mb_aws_invoke,sts get-caller-identity)
#   $(call mb_aws_invoke,s3 ls)
#   $(call mb_aws_invoke,s3api create-bucket --bucket my-bucket)
#   $(call mb_aws_invoke,ec2 describe-instances,--filters Name=instance-state-name,Values=running)
#
# Configurable vars (all optional):
#   mb_aws_cli       := aws                  # override CLI path/binary
#   mb_aws_profile   := myprof               # sets --profile
#   mb_aws_region    := eu-west-1            # sets --region
#   mb_aws_endpoint  := http://localhost:4566# sets --endpoint-url (e.g., LocalStack)
#   mb_aws_output    := json|text|table      # sets --output
#   mb_aws_pager_off := 1                    # if non-empty, adds --no-cli-pager
#   mb_aws_flags     := ...                  # any extra global flags you always want
#
# The optional second arg lets you pass ad-hoc flags per call.
# Global flags are placed before the service/command, per AWS CLI syntax.
# -------------------------------------------------------------------


define mb_aws_invoke
$(strip
  $(if $(call mb_cmd_exists,$(mb_aws_bin)),,\
    $(call mb_printf_error,AWS CLI not found or not on PATH: "$(mb_aws_bin)")\
  )

  $(eval $0_mb_aws_cmd := $(strip \
		$(mb_aws_bin) \
		$(if $(value mb_aws_profile),--profile $(mb_aws_profile)) \
		$(if $(value mb_aws_region),--region $(mb_aws_region)) \
		$(if $(value mb_aws_endpoint),--endpoint-url $(mb_aws_endpoint)) \
		$(if $(value mb_aws_output),--output $(mb_aws_output)) \
		$(if $(call mb_is_true,$(mb_aws_pager_off)),--no-cli-pager) \
		$(mb_aws_flags) \
		$(strip $1)) \
	)

  $(call mb_invoke,$($0_mb_aws_cmd))
)
endef

# -------------------------------------------------------------------
## Include sub modules

#mb_aws_mods_to_load := $(strip $(filter-out $(mb_aws_modules_ignore),$(mb_aws_modules)))
#$(if $(mb_aws_mods_to_load),\
#  $(foreach mod,$(mb_aws_modules),\
#	$(eval include $(aws_modules_dir)/$(mod).mk)\
#  )\
#)
#

endif # __MB_MODULES_AWS__
