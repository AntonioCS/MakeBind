#####################################################################################
# Project: MakeBind
# File: core/util/colours.mk
# Description: Colour codes for MakeBind, taken from https://stackoverflow.com/a/28938235/8715
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_COLOURS_MK__
__MB_CORE_UTIL_COLOURS_MK__ := 1

## https://duffney.io/usingansiescapesequencespowershell/#8-bit-256-color-foreground--background
## Note: `e is the escape character but is only valid on powershell 7.1 and above
mb_colour_opt_Escape = $(call mb_os_assign,`e,\033)#
#mb_colour_opt_Escape = $(call mb_os_assign,$(mb_rep_dollar)$(mb_lparen)char27$(mb_rparen),\033)#

# Reset
mb_colour_opt_Reset = $(mb_colour_opt_Escape)[0m      	 # Text Reset

# Regular Colors
mb_colour_opt_Black = $(mb_colour_opt_Escape)[0;30m
mb_colour_opt_Red = $(mb_colour_opt_Escape)[0;31m
mb_colour_opt_Green = $(mb_colour_opt_Escape)[0;32m
mb_colour_opt_Yellow = $(mb_colour_opt_Escape)[0;33m
mb_colour_opt_Blue = $(mb_colour_opt_Escape)[0;34m
mb_colour_opt_Purple = $(mb_colour_opt_Escape)[0;35m
mb_colour_opt_Cyan = $(mb_colour_opt_Escape)[0;36m
mb_colour_opt_White = $(mb_colour_opt_Escape)[0;37m

# Bold
mb_colour_opt_BBlack = $(mb_colour_opt_Escape)[1;30m
mb_colour_opt_BRed = $(mb_colour_opt_Escape)[1;31m
mb_colour_opt_BGreen = $(mb_colour_opt_Escape)[1;32m
mb_colour_opt_BYellow = $(mb_colour_opt_Escape)[1;33m
mb_colour_opt_BBlue = $(mb_colour_opt_Escape)[1;34m
mb_colour_opt_BPurple = $(mb_colour_opt_Escape)[1;35m
mb_colour_opt_BCyan = $(mb_colour_opt_Escape)[1;36m
mb_colour_opt_BWhite = $(mb_colour_opt_Escape)[1;37m

# Italic
mb_colour_opt_IBlack = $(mb_colour_opt_Escape)[3;30m
mb_colour_opt_IRed = $(mb_colour_opt_Escape)[3;31m
mb_colour_opt_IGreen = $(mb_colour_opt_Escape)[3;32m
mb_colour_opt_IYellow = $(mb_colour_opt_Escape)[3;33m
mb_colour_opt_IBlue = $(mb_colour_opt_Escape)[3;34m
mb_colour_opt_IPurple = $(mb_colour_opt_Escape)[3;35m
mb_colour_opt_ICyan = $(mb_colour_opt_Escape)[3;36m
mb_colour_opt_IWhite = $(mb_colour_opt_Escape)[3;37m

# Underline
mb_colour_opt_UBlack = $(mb_colour_opt_Escape)[4;30m
mb_colour_opt_URed = $(mb_colour_opt_Escape)[4;31m
mb_colour_opt_UGreen = $(mb_colour_opt_Escape)[4;32m
mb_colour_opt_UYellow = $(mb_colour_opt_Escape)[4;33m
mb_colour_opt_UBlue = $(mb_colour_opt_Escape)[4;34m
mb_colour_opt_UPurple = $(mb_colour_opt_Escape)[4;35m
mb_colour_opt_UCyan = $(mb_colour_opt_Escape)[4;36m
mb_colour_opt_UWhite = $(mb_colour_opt_Escape)[4;37m

# Background
mb_colour_opt_Bg_Black = $(mb_colour_opt_Escape)[40m
mb_colour_opt_Bg_Red = $(mb_colour_opt_Escape)[41m
mb_colour_opt_Bg_Green = $(mb_colour_opt_Escape)[42m
mb_colour_opt_Bg_Yellow = $(mb_colour_opt_Escape)[43m
mb_colour_opt_Bg_Blue = $(mb_colour_opt_Escape)[44m
mb_colour_opt_Bg_Purple = $(mb_colour_opt_Escape)[45m
mb_colour_opt_Bg_Cyan = $(mb_colour_opt_Escape)[46m
mb_colour_opt_Bg_White = $(mb_colour_opt_Escape)[47m

# High Intensity
mb_colour_opt_HI_Black = $(mb_colour_opt_Escape)[0;90m
mb_colour_opt_HI_Red = $(mb_colour_opt_Escape)[0;91m
mb_colour_opt_HI_Green = $(mb_colour_opt_Escape)[0;92m
mb_colour_opt_HI_Yellow = $(mb_colour_opt_Escape)[0;93m
mb_colour_opt_HI_Blue = $(mb_colour_opt_Escape)[0;94m
mb_colour_opt_HI_Purple = $(mb_colour_opt_Escape)[0;95m
mb_colour_opt_HI_Cyan = $(mb_colour_opt_Escape)[0;96m
mb_colour_opt_HI_White = $(mb_colour_opt_Escape)[0;97m

# Bold High Intensity
mb_colour_opt_HI_BBlack = $(mb_colour_opt_Escape)[1;90m      # Black
mb_colour_opt_HI_BRed = $(mb_colour_opt_Escape)[1;91m        # Red
mb_colour_opt_HI_BGreen = $(mb_colour_opt_Escape)[1;92m      # Green
mb_colour_opt_HI_BYellow = $(mb_colour_opt_Escape)[1;93m     # Yellow
mb_colour_opt_HI_BBlue = $(mb_colour_opt_Escape)[1;94m       # Blue
mb_colour_opt_HI_BPurple = $(mb_colour_opt_Escape)[1;95m     # Purple
mb_colour_opt_HI_BCyan = $(mb_colour_opt_Escape)[1;96m       # Cyan
mb_colour_opt_HI_BWhite = $(mb_colour_opt_Escape)[1;97m      # White

# High Intensity backgrounds
mb_colour_opt_HIBkg_Black = $(mb_colour_opt_Escape)[0;100m   # Black
mb_colour_opt_HIBkg_Red = $(mb_colour_opt_Escape)[0;101m     # Red
mb_colour_opt_HIBkg_Green = $(mb_colour_opt_Escape)[0;102m   # Green
mb_colour_opt_HIBkg_Yellow = $(mb_colour_opt_Escape)[0;103m  # Yellow
mb_colour_opt_HIBkg_Blue = $(mb_colour_opt_Escape)[0;104m    # Blue
mb_colour_opt_HIBkg_Purple = $(mb_colour_opt_Escape)[0;105m  # Purple
mb_colour_opt_HIBkg_Cyan = $(mb_colour_opt_Escape)[0;106m    # Cyan
mb_colour_opt_HIBkg_White = $(mb_colour_opt_Escape)[0;107m   # White

# Modes
mb_colour_opt_M_Bold = $(mb_colour_opt_Escape)[1m
mb_colour_opt_M_Dim = $(mb_colour_opt_Escape)[2m
mb_colour_opt_M_Italic = $(mb_colour_opt_Escape)[3m
mb_colour_opt_M_Underline = $(mb_colour_opt_Escape)[4m
mb_colour_opt_M_Blinking = $(mb_colour_opt_Escape)[5m
mb_colour_opt_M_Reverse = $(mb_colour_opt_Escape)[7m
mb_colour_opt_M_Invisible = $(mb_colour_opt_Escape)[7m
mb_colour_opt_M_Strikeout = $(mb_colour_opt_Escape)[9m


# $1 - colour name (e.g. Red, Green, etc) you can also pass the mode like BRed
# Modes are B for bold, I for italic, U for underline,
# $2 - text to colour or use mode on
# NOTE: Do not multiline this function as this might affect the text output (it will have spaces in it)
define mb_colour_text
$(strip
$(eval mb_colour_text_colour := $(if $(value mb_colour_opt_$1),$(mb_colour_opt_$1),$(error, Undefine colour/mode $1)))
$(mb_colour_text_colour)$2$(mb_colour_opt_Reset))
endef

mb_colour_bg = $(call mb_colour_text,Bg_$1,$2)
## High intensity background
mb_colour_hibg = $(call mb_colour_text,HIBkg_$1,$2)

mb_colour_mode_allowed_modes := Bold Dim Italic Underline Blinking Reverse Invisible Strikeout
define mb_colour_mode
$(strip
$(eval mb_colour_mode_mode := $(filter $(mb_colour_mode_allowed_modes),$1))
$(if $(mb_colour_mode_mode),
$(strip $(call mb_colour_text,M_$1,$2)),
$(error Undefine mode $1)))
endef

endif # __MB_CORE_UTIL_COLOURS_MK__
