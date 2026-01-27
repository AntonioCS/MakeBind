#####################################################################################
# Project: MakeBind
# File: core/util/os_detection.mk
# Description: OS detection functions for MakeBind (Linux/macOS only)
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_OS_DETECTION_MK__
__MB_CORE_UTIL_OS_DETECTION_MK__ := 1

mb_debug_os_detection ?= $(mb_debug)
ifeq ($(mb_debug_os_detection),0)
override mb_debug_os_detection :=#Empty
endif

## Windows detection - error early with helpful message
## Note: WSL sets OS=Windows_NT but uname returns Linux, so check uname first
mb_os_uname_check := $(shell uname -s 2>/dev/null)
mb_os_is_windows := $(if $(and $(value OS),$(findstring Windows_NT,$(OS)),$(if $(filter Linux Darwin,$(mb_os_uname_check)),,1)),$(mb_true))
$(if $(mb_os_is_windows),$(error MakeBind does not support Windows natively. Please use WSL (Windows Subsystem for Linux): https://learn.microsoft.com/en-us/windows/wsl/install))

mb_os_is_linux ?= $(mb_false)
mb_os_is_osx ?= $(mb_false)
mb_os_has_been_set ?= $(mb_false)
mb_os_detection_result_path ?= $(mb_makebind_tmp_path)/os_detection_result.mk
mb_os_detection_result_file_has_been_included ?= $(mb_false)

## NOTE: Make this as agnostic as possible. This cannot depend on anything that requires os detection
define mb_os_detection
$(strip
	$(if $(mb_os_detection_result_file_has_been_included),,$(eval -include $(mb_os_detection_result_path)))
	$(eval mb_os_detection_result_file_has_been_included := $(mb_true))
	$(if $(call mb_is_false,$(mb_os_has_been_set)),
		$(eval mb_os_has_been_set := $(mb_true))
		$(eval
			mb_os_is_linux := $(mb_false)
			mb_os_is_osx := $(mb_false)
			mb_os_is_linux_or_osx := $(mb_false)
		)
		$(eval mb_os_detection_OS := $(shell uname -s))
		$(if $(call mb_is_eq,$(mb_os_detection_OS),Linux),
			$(eval mb_os_is_linux := $(mb_true))
			,
			$(if $(call mb_is_eq,$(mb_os_detection_OS),Darwin),
				$(eval mb_os_is_osx := $(mb_true))
				,
				$(error ERROR: Unknown OS $(mb_os_detection_OS) detected. MakeBind only supports Linux and macOS.)
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
endef


## @function mb_os_call
## @desc Execute OS-specific command (Linux/macOS only)
## @arg 1: linux_cmd (required) - Command for Linux (also used as fallback for macOS)
## @arg 2: mac_cmd (optional) - Command for macOS, if not present Linux command is used
## @arg 3: use_shell (optional) - on/off, defaults to mb_os_call_use_shell
mb_os_call_use_shell ?= $(mb_on)

## NOTE: $(subst $(mb_dollar_replace),$(mb_dollar2),..) must be called at the very last minute
define mb_os_call
$(strip
	$(call mb_os_detection)
	$(eval $0_cmd := $(strip $(if $(mb_os_is_linux),\
		$1,\
		$(if $(value 2),\
			$2,\
			$1 \
	))))
	$(eval $0_use_shell_or_not := $(if $(value 3),$3,$($0_use_shell)))
	$(if $(mb_debug_os_detection),$(warning DEBUG: $0_cmd: $($0_cmd)))
	$(if $(call mb_is_on,$($0_use_shell_or_not)),
		$(shell $(subst $(mb_dollar_replace),$(mb_dollar2),$($0_cmd))),
		$(subst $(mb_dollar_replace),$(mb_dollar2),$($0_cmd))
	)
)
endef

## @function mb_os_assign
## @desc Get OS-specific value without shell execution (Linux/macOS only)
## @arg 1: linux_value (required) - Value for Linux
## @arg 2: mac_value (optional) - Value for macOS, if not present Linux value is used
mb_os_assign = $(strip $(call mb_os_call,$1,$(if $(value 2),$2),$(mb_off)))

endif # __MB_CORE_UTIL_OS_DETECTION_MK__
