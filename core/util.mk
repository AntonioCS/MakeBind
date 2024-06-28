#####################################################################################
# Project: MakeBind
# File: core/util.mk
# Description: Utility functions and targets MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_MK__
__MB_CORE_UTIL_MK__ := 1


# NOTE: Do not call functions inside this function as the helper functions might not be available (like mb_debug_print)
define mb_load_utils
$(eval mb_load_utils_path := $(mb_core_path)/util)
$(eval mb_load_utils_files := $(wildcard $(mb_load_utils_path)/*.mk))
$(foreach mb_load_utils_file,$(mb_load_utils_files),
	$(eval include $(mb_load_utils_file))
)
endef

$(call mb_load_utils)
#include $(mb_core_path)/util/cache.mk
#include $(mb_core_path)/util/colours.mk
#include $(mb_core_path)/util/debug.mk
#include $(mb_core_path)/util/os_detection.mk
#include $(mb_core_path)/util/targets.mk

define mb_shell_tolower
$(shell echo $1 | tr '[:upper:]' '[:lower:]')
endef

define mb_tolower
$(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,\
$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,\
$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,\
$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,\
$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))
endef


define mb_shell_toupper
$(shell echo $(1) | tr '[:lower:]' '[:upper:]')
endef

define mb_toupper
$(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,\
$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,\
$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,\
$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,\
$(subst y,Y,$(subst z,Z,$1)))))))))))))))))))))))))
endef


## If helper functions
mb_is_eq = $(if $(filter $1,$2),1)
mb_is_neq = $(if $(call mb_is_eq,$1,$2),,1)
mb_is_on = $(call mb_is_eq,$1,1)
mb_is_off = $(call mb_is_eq,$1,0)
mb_is_empty = $(if $1,,1)
mb_is_false = $(call mb_is_empty,$1)
mb_is_true = $(call mb_is_eq,$1,$(mb_true))


# File helpers
mb_exists = $(if $(wildcard $1),1)
mb_not_exists = $(if $(call mb_exists,$1),,1)

## Useful variables
mb_comma := ,
mb_empty := #
mb_space := $(mb_empty) $(mb_empty)#
mb_warning_triangle := ⚠#
mb_hash := \##
mb_percent := %#
mb_colon := :#
mb_equal := =#
mb_lparen := (#
mb_rparen := )#
mb_dollar := \$
mb_dollar_replace := ø#Char 248
mb_true := 1
mb_false := $(mb_empty)
mb_on := 1
mb_off := 0

# Time helpers in seconds
mb_time_minute := 60
mb_time_hour := 3600
mb_time_day := 86400

# Powershell helper
mb_powershell = powershell -Command '$(strip $1)'

define mb_timestamp
$(call mb_os_call,
	$(call mb_powershell,[math]::Floor((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds)),\
	date +%s\
)
endef

define mb_expression
$(call mb_os_call,
	$(call mb_powershell,$1),\
	echo $1 | bc\
)
endef

mb_add = $(call mb_expression,$1+$2)
mb_dec = $(call mb_expression,$1-$2)
mb_mul = $(call mb_expression,$1*$2)
mb_div = $(call mb_expression,$1/$2)

## Random numbers

# $1: lower limit (default: 1)
# $2: upper limit (default: 65534)
define mb_random
$(strip
	$(eval
	mb_random_lo := $(if $(value 1),$1,1)
	mb_random_hi := $(if $(value 2),$2,65534)
	)
	$(call mb_os_call,
    	$(call mb_powershell,Get-Random -Minimum $(mb_random_lo) -Maximum $(mb_random_hi)),\
    	shuf -i $(mb_random_lo)-$(mb_random_hi) -n 1,\
    	jot -r 1 $(mb_random_lo) $(mb_random_hi)\
    )
)
endef

mb_remove_spaces = $(subst $(mb_space),$(mb_empty),$1)

endif # __MB_CORE_UTIL_MK__
