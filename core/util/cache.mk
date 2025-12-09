#####################################################################################
# Project: MakeBind
# File: core/util/cache.mk
# Description: Cache functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_CACHE_MK__
__MB_CORE_UTIL_CACHE_MK__ := 1


mb_debug_cache ?= $(mb_debug)
mb_cache_folder_path ?= $(mb_makebind_tmp_path)/cache
mb_cache_file_extension ?= cache.mk
mb_cache_ttl_extension ?= ttl.cache.mk
mb_cache_auto_add_prefix ?= $(mb_true)# Add mb_project_prefix to cache key automatically

define mb_cache_ttl_contents
mb_cache_ttl_$(mb_cache_key) := $(mb_cache_write_ttl)
endef

# Prepares needed variables for cache functions
#$1: key
## Creates variable mb_cache_key, mb_cache_file_path and mb_cache_ttl_file_path all based on they key
define mb_cache_create_needed_data
$(strip
$(eval mb_cache_key := $(if $(mb_cache_auto_add_prefix),$(strip $(mb_project_prefix)_))$(if $(value 1),$1,$(error $0 - Key is required)))
$(eval
	mb_cache_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_file_extension)
	mb_cache_ttl_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_ttl_extension)
)
)
endef


#$1: key
#$2: value
#$3: ttl in seconds
define mb_cache_write
$(strip
$(call mb_cache_create_needed_data,$1)
$(call mb_debug_print,Writing cache file $(mb_cache_file_path),$(mb_debug_cache))
$(if $(value 2),,$(call mb_printf_error, $0 - Value is required))
$(file >$(mb_cache_file_path),$2)
$(if $(value 3),
	$(eval mb_cache_write_ttl := $(call mb_add,$(call mb_timestamp),$3))
	$(file >$(mb_cache_ttl_file_path),$(mb_cache_ttl_contents))
	$(call mb_debug_print,Writing cache ttl file $(mb_cache_ttl_file_path) with value $(mb_cache_write_ttl),$(mb_debug_cache))
)
)
endef


define mb_cache_write_OLD
$(strip
$(eval mb_cache_key := $(if $(mb_cache_auto_add_prefix),$(strip $(mb_project_prefix)_))$(if $(value 1,$1),$(error $0 - Key is required)))
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

define mb_cache_has
$(strip
	$(call mb_cache_create_needed_data,$1)
	$(eval mb_cache_has_result := $(mb_false))
	$(if $(call mb_exists,$(mb_cache_file_path)),
    	$(eval mb_cache_has_result := $(mb_true))
    	$(call mb_debug_print,Found cache file: $(mb_cache_file_path),$(mb_debug_cache))

    	$(if $(call mb_exists,$(mb_cache_ttl_file_path)),
    		$(call mb_debug_print,Found ttl file,$(mb_debug_cache))
    		$(eval include $(mb_cache_ttl_file_path))
    		$(eval mb_cache_ttl_result := $(intcmp $(call mb_timestamp),$(mb_cache_ttl_$(mb_cache_key)),-1,0,1))
    		$(if $(call mb_is_eq,$(mb_cache_ttl_result),-1),
    			$(call mb_debug_print,Cache has not expired - $(mb_cache_ttl_result),$(mb_debug_cache))
    		,
    			$(call mb_debug_print,Cache has expired - $(mb_cache_ttl_result),$(mb_debug_cache))
    			$(eval mb_cache_has_result := $(mb_false))
    		)
    	)
    )
    $(mb_cache_has_result)
)
endef

# Can't use $(strip
#$1: key
#$2: Where to set the value (variable name)
define mb_cache_read
$(if $(call mb_cache_has,$1),
	$(call mb_debug_print,Including cache file $(mb_cache_file_path),$(mb_debug_cache))
	$(eval $2 := $(file < $(mb_cache_file_path)))
,
	$(call mb_debug_print,Cache has expired,$(mb_debug_cache))
)
endef


define mb_cache_read_OLD
$(eval mb_cache_key := $(if $(mb_cache_auto_add_prefix),$(strip $(mb_project_prefix)_))$(if $(value 1,$1),$(error $0 - Key is required)))
$(eval
	mb_cache_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_file_extension)
	mb_cache_ttl_file_path := $(mb_cache_folder_path)/$(mb_cache_key).$(mb_cache_ttl_extension)
)
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


## Skip target definitions when loaded dynamically (e.g., during test discovery)
ifndef __MB_TEST_DISCOVERY__

mb/cache/clear: ## Clear all cache files
	$(if $(call mb_exists,$(mb_cache_folder_path)),
		$(eval $@_cmd := rm -rf $(mb_cache_folder_path)/*$(mb_cache_file_extension))
		$(call mb_invoke,$($@_cmd),$@_exit,$@_output)
	,
		$(call mb_printf_info,Cache folder does not exist, nothing to clear)
	)

endif # __MB_TEST_DISCOVERY__

endif # __MB_CORE_UTIL_CACHE_MK__
