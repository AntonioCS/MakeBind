#####################################################################################
# Project: MakeBind
# File: core/util.mk
# Description: Utility functions and targets MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_MK__
__MB_CORE_UTIL_MK__ := 1

mb_debug_util ?= $(mb_debug)

# NOTE: Do not call functions inside this function as the helper functions might not be available (like mb_debug_print)
#define mb_load_utils
#$(eval mb_load_utils_path := $(mb_core_path)/util)
#$(eval mb_load_utils_files := $(wildcard $(mb_load_utils_path)/*.mk))
#$(foreach mb_load_utils_file,$(mb_load_utils_files),
#	$(eval include $(mb_load_utils_file))
#)
#endef

#$(call mb_load_utils)

## NOTE: order is important
include $(mb_core_path)/util/os_detection.mk
include $(mb_core_path)/util/cache.mk
include $(mb_core_path)/util/colours.mk
include $(mb_core_path)/util/debug.mk
include $(mb_core_path)/util/git.mk

include $(mb_core_path)/util/variables.mk

mb_tolower_sh = $(strip $(shell echo $1 | tr '[:upper:]' '[:lower:]'))


define mb_tolower
$(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,\
$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,\
$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,\
$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,\
$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))
endef


mb_toupper_sh = $(strip $(shell echo $1 | tr '[:lower:]' '[:upper:]'))

define mb_toupper
$(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,\
$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,\
$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,\
$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,\
$(subst y,Y,$(subst z,Z,$1))))))))))))))))))))))))))
endef


## If helper functions
mb_is_eq = $(if $(filter $1,$2),$(mb_true),$(mb_false))
mb_is_neq = $(if $(call mb_is_eq,$1,$2),$(mb_false),$(mb_true))
mb_is_on = $(call mb_is_eq,$(strip $1),$(mb_on))
mb_is_off = $(call mb_is_eq,$(strip $1),$(mb_off))
mb_is_empty = $(if $(strip $1),$(mb_false),$(mb_true))
mb_is_false = $(call mb_is_empty,$(strip $1))
mb_is_true = $(call mb_is_eq,$(strip $1),$1)
mb_is_url = $(strip $(if $(filter http://% https://%,$(strip $1)),$(mb_true),$(mb_false)))#

## Note: Make sure you escape $
define mb_is_regex_match
$(strip
	$(eval $0_text := $(strip $(subst ',\',$1)))
	$(eval $0_regex := $(strip $2))
	$(eval $0_shell_cmd := echo '$($0_text)' | grep -P '$($0_regex)' > /dev/null && echo 1)
	$(call mb_debug_print, Text: $($0_text),$(mb_debug_util))
	$(call mb_debug_print, Regex: $($0_regex),$(mb_debug_util))
	$(call mb_debug_print, Shell: $($0_shell_cmd),$(mb_debug_util))
	$(shell $($0_shell_cmd))
)
endef
# printf ".+?"\s"\[\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\]"\s"\[MakeBind\]"\s"printf tests passed";printf "\\n";

# File helpers
mb_exists = $(if $(wildcard $1),$(mb_true))
mb_not_exists = $(if $(call mb_exists,$1),,$(mb_true))
mb_is_symlink = $(if $(shell test -L "$1" && echo 1),$(mb_true))
mb_is_not_symlink = $(if $(call mb_is_symlink,$1),,$(mb_true))

## Useful variables

## @function mb_timestamp
## @desc Get current Unix timestamp
## @returns Unix timestamp as integer
mb_timestamp = $(call mb_os_call,date +%s)

mb_date_now = date "+%Y-%m-%d %H:%M"

## @function mb_expression
## @desc Evaluate a mathematical expression using bc
## @arg 1: expression (required) - Mathematical expression (e.g., "1+1")
## @returns Result of the expression
mb_expression = $(call mb_os_call,echo $1 | bc)

mb_add = $(call mb_expression,$1+$2)
mb_sub = $(call mb_expression,$1-$2)
mb_mul = $(call mb_expression,$1*$2)
mb_div = $(call mb_expression,$1/$2)

## NOTE: This will not return the value, it will change the value of the variable **ONLY**
mb_inc = $(eval $1 := $(call mb_add,$($1),1))
mb_dec = $(eval $1 := $(call mb_sub,$($1),1))

## Random numbers

## @function mb_random
## @desc Generate a random number within bounds
## @arg 1: lower_limit (optional) - Lower bound (default: 1)
## @arg 2: upper_limit (optional) - Upper bound (default: 65534)
## @returns Random integer within bounds
mb_random_lower_bound := 1
mb_random_upper_bound := 65534
define mb_random
$(strip
	$(eval
	mb_random_lo := $(if $(value 1),$1,$(mb_random_lower_bound))
	mb_random_hi := $(if $(value 2),$2,$(mb_random_upper_bound))
	)
	$(call mb_os_call,\
		shuf -i $(mb_random_lo)-$(mb_random_hi) -n 1,\
		jot -r 1 $(mb_random_lo) $(mb_random_hi)\
	)
)
endef

mb_remove_spaces = $(subst $(mb_space),$(mb_empty),$1)


mb_rreplacer = $(subst ",', $(subst $(mb_dollar_replace),$(mb_dollar),$1))



mb_space_guard_word := __SPACE__#
mb_space_guard = $(subst $(mb_space),$(mb_space_guard_word),$(strip $1))#
mb_space_unguard = $(subst $(mb_space_guard_word),$(mb_space),$(strip $1))#


## WIP
define ___mb_array_from_file
$(strip
	$(eval $0_file := $(strip $1))
	$(eval $0_var_name := $(strip $2))
	$(eval $0_total_lines := $(shell grep -c "" $($0_file)))
	$(info Var name: $($0_var_name))
	$(info File: $($0_file))
	$(info Total lines: $($0_total_lines))
	$(eval $0_list := $(shell seq 0 $$\(\($($0_total_lines)-1\)\) ) )
	$(info Total lines: $($0_total_lines))
	$(info List: $($0_list))
)
endef
#	$(foreach $0_i,$($0_list),
#		$(eval $($0_var_name)_$($0_i) := $(shell sed -n '$$($($0_i)+1){p;q}' $($0_file)))
#	)


## @function mb_downloader
## @desc Download a file from URL (uses curl which is available on both Linux and macOS)
## @arg 1: url (required) - URL to download
## @arg 2: output (required) - Output file path
define mb_downloader
$(strip
	$(eval $0_url := $(strip $1))
	$(eval $0_output := $(strip $2))
	$(shell curl -sS -L -o $($0_output) $($0_url))
)
endef


## @function mb_unzip
## @desc Extract a zip file
## @arg 1: input (required) - Input zip file path
## @arg 2: output (required) - Output directory path
define mb_unzip
$(strip
	$(eval $0_input := $(strip $1))
	$(eval $0_output := $(strip $2))
	$(call mb_os_call,unzip -qq $($0_input) -d $($0_output))
)
endef

## @function mb_cmd_exists
## @desc Check if a command exists in PATH
## @arg 1: command (required) - Command to check
## @returns mb_true if exists, mb_false otherwise
mb_cmd_exists = $(strip $(if $(shell command -v $1 >/dev/null 2>&1 && echo yes), $(mb_true), $(mb_false)))



# Useful for checking required env vars.
# Return the value of VAR (by name) or error with "Missing VAR=HINT".
# Usage: $(call mb_require_value,var_name,[hint value])
mb_require_value = $(strip $(if $(strip $(value $1)),$(value $1),$(call mb_printf_error,Missing $1$(if $(value 2),=$2))))

# Usage: $(call mb_require_into,<local dest var>,<env src var>,<hint>)
# Example: $(call mb_require_into,$@_aws_bucket,aws_bucket,<bucket[/prefix]>)
define mb_require_into
$(strip
	$(if $(value 1),,$(call mb_printf_error,$0: missing parameter 1 (dest var)))
	$(if $(value 2),,$(call mb_printf_error,$0: missing parameter 2 (src var)))
	$(if $(value 3),,$(call mb_printf_error,$0: missing parameter 3 (hint)))
	$(eval $1 := $(call mb_require_value,$2,$3))
)
endef

endif # __MB_CORE_UTIL_MK__
