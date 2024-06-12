#####################################################################################
# Project: MakeBind
# File: core/util/cache.mk
# Description: Cache functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_OS_DETECTION_MK__
__MB_CORE_UTIL_OS_DETECTION_MK__ := 1

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
		$(if $(call mb_is_eq,$(OS),Windows_NT),
			$(eval mb_os_is_windows := $(mb_true))
			,
			$(eval OS := $(shell uname -s))
			$(if $(call mb_is_eq,$(OS),Linux),
				$(eval mb_os_is_linux := $(mb_true))
			)
			$(if $(call mb_is_eq,$(OS),Darwin),
				$(eval mb_os_is_osx := $(mb_true))
			)
		)
		$(file >$(mb_os_detection_result_path),$(mb_os_detection_result_content))
	)
)
endef

define mb_os_detection_result_content
mb_os_has_been_set := $(mb_os_has_been_set)
mb_os_is_linux := $(mb_os_is_linux)
mb_os_is_osx := $(mb_os_is_osx)
mb_os_is_windows := $(mb_os_is_windows)
endef


endif # __MB_CORE_UTIL_OS_DETECTION_MK__
