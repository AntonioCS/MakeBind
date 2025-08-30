#####################################################################################
# Project: MakeBind
# File: core/util/cache.mk
# Description: Cache functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_VARIABLES_MK__
__MB_CORE_UTIL_VARIABLES_MK__ := 1

mb_comma := ,#
mb_empty := #
mb_space := $(mb_empty) $(mb_empty)#
mb_warning_triangle := ⚠#
mb_check_mark := ✓#
mb_cross_mark := ✗#
mb_hash := \##
mb_percent := %#
mb_colon := :#
mb_scolon := ;#
mb_equal := =#
mb_lparen := (#
mb_rparen := )#
mb_lcurly := {#
mb_rcurly := }#
mb_dollar := \$
mb_dollar2 := $$## This seems to work better when replacing $(mb_dollar_replace)
mb_dollar_replace := ø#Char 248
mb_true := 1#
mb_false := $(mb_empty)#
mb_on := 1#
mb_off := 0#

# Time helpers in seconds
mb_time_minute := 60
mb_time_hour := 3600
mb_time_day := 86400

endif # __MB_CORE_UTIL_VARIABLES_MK__
