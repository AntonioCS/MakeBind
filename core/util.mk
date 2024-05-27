#####################################################################################
# Project: MakeBind
# File: core/util.mk
# Description: Utility functions and targets MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_MK__
__MB_CORE_UTIL_MK__ := 1

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
#define newline :=
#$(empty)
#$(empty)
#endef

endif # __MB_CORE_UTIL_MK__
