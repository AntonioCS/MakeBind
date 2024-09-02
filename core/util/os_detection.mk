#####################################################################################
# Project: MakeBind
# File: core/util/cache.mk
# Description: Cache functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_OS_DETECTION_MK__
__MB_CORE_UTIL_OS_DETECTION_MK__ := 1

mb_debug_os_detection ?= $(mb_debug)
ifeq ($(mb_debug_os_detection),0)
override mb_debug_os_detection :=#Empty
endif

mb_os_is_linux ?= $(mb_false)
mb_os_is_osx ?= $(mb_false)
mb_os_is_windows ?= $(mb_false)
mb_os_has_been_set ?= $(mb_false)
mb_os_detection_result_path ?= $(mb_makebind_tmp_path)/os_detection_result.mk
mb_os_detection_result_file_has_been_included ?= $(mb_false)
## These are set on windows
OS ?= unknown
PROCESSOR_ARCHITEW6432 ?= unknown
PROCESSOR_ARCHITECTURE ?= unknown

## NOTE: Make this as agnostic as possible. This cannot depend on anything that requires os detection
define mb_os_detection
$(strip
	$(if $(mb_os_detection_result_file_has_been_included),,$(eval -include $(mb_os_detection_result_path)))
	$(eval mb_os_detection_result_file_has_been_included := $(mb_true))
	$(if $(call mb_is_false,$(mb_os_has_been_set)),
		$(eval mb_os_has_been_set := $(mb_true))
		$(eval
			mb_os_is_windows := $(mb_false)
			mb_os_is_linux := $(mb_false)
			mb_os_is_osx := $(mb_false)
			mb_os_is_linux_or_osx := $(mb_false)
		)
		$(if $(call mb_is_eq,$(OS),Windows_NT),
			$(eval mb_os_is_windows := $(mb_true))
			,
			$(eval mb_os_detection_OS := $(shell uname -s))
			$(if $(call mb_is_eq,$(mb_os_detection_OS),Linux),
				$(eval mb_os_is_linux := $(mb_true))
				,
				$(if $(call mb_is_eq,$(mb_os_detection_OS),Darwin),
					$(eval mb_os_is_osx := $(mb_true))
					,
					$(error ERROR: Unknown OS $(mb_os_detection_OS) detected, please add support for it in core/util/os_detection.mk)
				)
			)
		)
		$(eval mb_os_is_linux_or_osx := $(if $(or $(mb_os_is_linux),$(mb_os_is_osx)),$(mb_true)))
		$(file >$(mb_os_detection_result_path),$(mb_os_detection_result_content))
	)
)
endef

define mb_os_detection_result_content
mb_os_has_been_set := $(mb_os_has_been_set)#
mb_os_is_linux := $(mb_os_is_linux)#
mb_os_is_osx := $(mb_os_is_osx)#
mb_os_is_linux_or_osx := $(mb_os_is_linux_or_osx)#
mb_os_is_windows := $(mb_os_is_windows)#
endef


#$1 - Windows command
#$2 - Linux command
#$3 - Mac command, if not present Linux command will be used
#$4 - Use shell (on/off)
mb_os_call_use_shell ?= $(mb_on)

## NOTE: $(subst $(mb_dollar_replace),$(mb_dollar2),..) must be called at the very last minute
define mb_os_call
$(strip
	$(call mb_os_detection)
	$(eval $0_cmd := $(strip $(if $(mb_os_is_windows),\
		$1,\
		$(if $(mb_os_is_linux),\
			$2,\
			$(if $(value 3),\
				$3,\
				$2 \
	)))))
	$(eval $0_use_shell_or_not := $(if $(value 4),$4,$($0_use_shell)))
	$(if $(mb_debug_os_detection),$(warning DEBUG: $0_cmd: $($0_cmd)))
	$(if $(call mb_is_on,$($0_use_shell_or_not)),
		$(shell $(subst $(mb_dollar_replace),$(mb_dollar2),$($0_cmd))),
		$(subst $(mb_dollar_replace),$(mb_dollar2),$($0_cmd))
	)
)
endef

mb_os_assign = $(strip $(call mb_os_call,$1,$2,$(if $(value 3),$3),$(mb_off)))

endif # __MB_CORE_UTIL_OS_DETECTION_MK__
