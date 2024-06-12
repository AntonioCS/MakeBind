#####################################################################################
# Project: MakeBind
# File: core/util/cache.mk
# Description: Cache functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_CACHE_MK__
__MB_CORE_UTIL_CACHE_MK__ := 1


mb_cache_folder_path ?= $(mb_makebind_tmp_path)
mb_cache_file_extension ?= cache.mk
mb_cache_ttl_extension ?= ttl.cache.mk
mb_debug_cache ?= $(mb_debug)

define mb_cache_ttl_contents
mb_cache_ttl_$(mb_cache_key) := $(mb_cache_write_ttl)
endef

#$1: key
#$2: value
#$3: ttl in seconds
define mb_cache_write
$(strip
$(eval mb_cache_key := $1)
$(eval mb_cache_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_file_extension))
$(call mb_debug_print,Writing cache file $(mb_cache_file_path),$(mb_debug_cache))
$(file >$(mb_cache_file_path),$2)
$(if $(value 3),
	$(eval mb_cache_write_ttl := $(call mb_add,$(call mb_timestamp),$3))
	$(eval mb_cache_ttl_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_ttl_extension))
	$(file >$(mb_cache_ttl_file_path),$(mb_cache_ttl_contents))
	$(call mb_debug_print,Writing cache ttl file $(mb_cache_ttl_file_path) with value $(mb_cache_write_ttl),$(mb_debug_cache))
)
)
endef

#$1: key
define mb_cache_read
$(eval mb_cache_key := $1)
$(eval mb_cache_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_file_extension))
$(eval mb_cache_ttl_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_ttl_extension))

$(if $(call mb_exists,$(mb_cache_file_path)),
	$(eval mb_cache_include_file := $(mb_true))
	$(call mb_debug_print,Found cache file: $(mb_cache_file_path),$(mb_debug_cache))

	$(if $(call mb_exists,$(mb_cache_ttl_file_path)),
		$(call mb_debug_print,Found ttl file,$(mb_debug_cache))
		$(eval include $(mb_cache_ttl_file_path))
		$(eval mb_cache_ttl_result := $(intcmp $(call mb_timestamp),$(mb_cache_ttl_$(mb_cache_key)),-1,0,1))
		$(if $(call mb_is_eq,$(mb_cache_ttl_result),-1),
			$(call mb_debug_print,Cache has not expired - $(mb_cache_ttl_result),$(mb_debug_cache))
			,
			$(call mb_debug_print,Cache has expired - $(mb_cache_ttl_result),$(mb_debug_cache))
			$(eval mb_cache_include_file := $(mb_false))
		)
	)

	$(if $(mb_cache_include_file),
		$(call mb_debug_print,Including cache file $(mb_cache_file_path),$(mb_debug_cache))
		$(eval include $(mb_cache_file_path))
		,
		$(call mb_debug_print,Cache has expired,$(mb_debug_cache))
	)
	,
	$(call mb_debug_print,Not found cache file for key: $(mb_cache_key) ,$(mb_debug_cache))
)


endef

endif # __MB_CORE_UTIL_CACHE_MK__
