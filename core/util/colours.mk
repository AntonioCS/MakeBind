#####################################################################################
# Project: MakeBind
# File: core/util/colours.mk
# Description: Colour codes for MakeBind, taken from https://stackoverflow.com/a/28938235/8715
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_COLOURS_MK__
__MB_CORE_UTIL_COLOURS_MK__ := 1


# Reset
mb_colour_opt_Reset := \033[0m      	 # Text Reset

# Regular Colors
mb_colour_opt_Black := \033[0;30m
mb_colour_opt_Red := \033[0;31m
mb_colour_opt_Green := \033[0;32m
mb_colour_opt_Yellow := \033[0;33m
mb_colour_opt_Blue := \033[0;34m
mb_colour_opt_Purple := \033[0;35m
mb_colour_opt_Cyan := \033[0;36m
mb_colour_opt_White := \033[0;37m

# Bold
mb_colour_opt_BBlack := \033[1;30m
mb_colour_opt_BRed := \033[1;31m
mb_colour_opt_BGreen := \033[1;32m
mb_colour_opt_BYellow := \033[1;33m
mb_colour_opt_BBlue := \033[1;34m
mb_colour_opt_BPurple := \033[1;35m
mb_colour_opt_BCyan := \033[1;36m
mb_colour_opt_BWhite := \033[1;37m

# Italic
mb_colour_opt_IBlack := \033[3;30m
mb_colour_opt_IRed := \033[3;31m
mb_colour_opt_IGreen := \033[3;32m
mb_colour_opt_IYellow := \033[3;33m
mb_colour_opt_IBlue := \033[3;34m
mb_colour_opt_IPurple := \033[3;35m
mb_colour_opt_ICyan := \033[3;36m
mb_colour_opt_IWhite := \033[3;37m

# Underline
mb_colour_opt_UBlack := \033[4;30m
mb_colour_opt_URed := \033[4;31m
mb_colour_opt_UGreen := \033[4;32m
mb_colour_opt_UYellow := \033[4;33m
mb_colour_opt_UBlue := \033[4;34m
mb_colour_opt_UPurple := \033[4;35m
mb_colour_opt_UCyan := \033[4;36m
mb_colour_opt_UWhite := \033[4;37m

# Background
mb_colour_opt_Bg_Black := \033[40m
mb_colour_opt_Bg_Red := \033[41m
mb_colour_opt_Bg_Green := \033[42m
mb_colour_opt_Bg_Yellow := \033[43m
mb_colour_opt_Bg_Blue := \033[44m
mb_colour_opt_Bg_Purple := \033[45m
mb_colour_opt_Bg_Cyan := \033[46m
mb_colour_opt_Bg_White := \033[47m

# High Intensity
mb_colour_opt_HI_Black := \033[0;90m
mb_colour_opt_HI_Red := \033[0;91m
mb_colour_opt_HI_Green := \033[0;92m
mb_colour_opt_HI_Yellow := \033[0;93m
mb_colour_opt_HI_Blue := \033[0;94m
mb_colour_opt_HI_Purple := \033[0;95m
mb_colour_opt_HI_Cyan := \033[0;96m
mb_colour_opt_HI_White := \033[0;97m

# Bold High Intensity
mb_colour_opt_HI_BBlack := \033[1;90m      # Black
mb_colour_opt_HI_BRed := \033[1;91m        # Red
mb_colour_opt_HI_BGreen := \033[1;92m      # Green
mb_colour_opt_HI_BYellow := \033[1;93m     # Yellow
mb_colour_opt_HI_BBlue := \033[1;94m       # Blue
mb_colour_opt_HI_BPurple := \033[1;95m     # Purple
mb_colour_opt_HI_BCyan := \033[1;96m       # Cyan
mb_colour_opt_HI_BWhite := \033[1;97m      # White

# High Intensity backgrounds
mb_colour_opt_HIBkg_Black := \033[0;100m   # Black
mb_colour_opt_HIBkg_Red := \033[0;101m     # Red
mb_colour_opt_HIBkg_Green := \033[0;102m   # Green
mb_colour_opt_HIBkg_Yellow := \033[0;103m  # Yellow
mb_colour_opt_HIBkg_Blue := \033[0;104m    # Blue
mb_colour_opt_HIBkg_Purple := \033[0;105m  # Purple
mb_colour_opt_HIBkg_Cyan := \033[0;106m    # Cyan
mb_colour_opt_HIBkg_White := \033[0;107m   # White

# Modes
mb_colour_opt_M_Bold := \033[1m
mb_colour_opt_M_Dim := \033[2m
mb_colour_opt_M_Italic := \033[3m
mb_colour_opt_M_Underline := \033[4m
mb_colour_opt_M_Blinking := \033[5m
mb_colour_opt_M_Reverse := \033[7m
mb_colour_opt_M_Invisible := \033[7m
mb_colour_opt_M_Strikeout := \033[9m


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
