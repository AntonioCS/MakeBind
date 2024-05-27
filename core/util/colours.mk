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
mb_colour_reset:=\033[0m      	 # Text Reset

# Regular Colors
mb_colour_Black:=\033[0;30m        # Black
mb_colour_Red:=\033[0;31m          # Red
mb_colour_Green:=\033[0;32m        # Green
mb_colour_Yellow:=\033[0;33m       # Yellow
mb_colour_Blue:=\033[0;34m         # Blue
mb_colour_Purple:=\033[0;35m       # Purple
mb_colour_Cyan:=\033[0;36m         # Cyan
mb_colour_White:=\033[0;37m        # White

# Bold
mb_colour_BBlack:=\033[1;30m       # Black
mb_colour_BRed:=\033[1;31m         # Red
mb_colour_BGreen:=\033[1;32m       # Green
mb_colour_BYellow:=\033[1;33m      # Yellow
mb_colour_BBlue:=\033[1;34m        # Blue
mb_colour_BPurple:=\033[1;35m      # Purple
mb_colour_BCyan:=\033[1;36m        # Cyan
mb_colour_BWhite:=\033[1;37m       # White

# Italic
mb_colour_IBlack:=\033[3;30m       # Black
mb_colour_IRed:=\033[3;31m         # Red
mb_colour_IGreen:=\033[3;32m       # Green
mb_colour_IYellow:=\033[3;33m      # Yellow
mb_colour_IBlue:=\033[3;34m        # Blue
mb_colour_IPurple:=\033[3;35m      # Purple
mb_colour_ICyan:=\033[3;36m        # Cyan
mb_colour_IWhite:=\033[3;37m       # White

# Underline
mb_colour_UBlack:=\033[4;30m       # Black
mb_colour_URed:=\033[4;31m         # Red
mb_colour_UGreen:=\033[4;32m       # Green
mb_colour_UYellow:=\033[4;33m      # Yellow
mb_colour_UBlue:=\033[4;34m        # Blue
mb_colour_UPurple:=\033[4;35m      # Purple
mb_colour_UCyan:=\033[4;36m        # Cyan
mb_colour_UWhite:=\033[4;37m       # White

# Background
mb_colour_Bg_Black:=\033[40m       # Black
mb_colour_Bg_Red:=\033[41m         # Red
mb_colour_Bg_Green:=\033[42m       # Green
mb_colour_Bg_Yellow:=\033[43m      # Yellow
mb_colour_Bg_Blue:=\033[44m        # Blue
mb_colour_Bg_Purple:=\033[45m      # Purple
mb_colour_Bg_Cyan:=\033[46m        # Cyan
mb_colour_Bg_White:=\033[47m       # White

# High Intensity
mb_colour_IBlack:=\033[0;90m       # Black
mb_colour_IRed:=\033[0;91m         # Red
mb_colour_IGreen:=\033[0;92m       # Green
mb_colour_IYellow:=\033[0;93m      # Yellow
mb_colour_IBlue:=\033[0;94m        # Blue
mb_colour_IPurple:=\033[0;95m      # Purple
mb_colour_ICyan:=\033[0;96m        # Cyan
mb_colour_IWhite:=\033[0;97m       # White

# Bold High Intensity
mb_colour_BIBlack:=\033[1;90m      # Black
mb_colour_BIRed:=\033[1;91m        # Red
mb_colour_BIGreen:=\033[1;92m      # Green
mb_colour_BIYellow:=\033[1;93m     # Yellow
mb_colour_BIBlue:=\033[1;94m       # Blue
mb_colour_BIPurple:=\033[1;95m     # Purple
mb_colour_BICyan:=\033[1;96m       # Cyan
mb_colour_BIWhite:=\033[1;97m      # White

# High Intensity backgrounds
mb_colour_On_IBlack:=\033[0;100m   # Black
mb_colour_On_IRed:=\033[0;101m     # Red
mb_colour_On_IGreen:=\033[0;102m   # Green
mb_colour_On_IYellow:=\033[0;103m  # Yellow
mb_colour_On_IBlue:=\033[0;104m    # Blue
mb_colour_On_IPurple:=\033[0;105m  # Purple
mb_colour_On_ICyan:=\033[0;106m    # Cyan
mb_colour_On_IWhite:=\033[0;107m   # White

# Modes
mb_colour_m_bold = \033[1m
mb_colour_m_dim = \033[2m
mb_colour_m_italic = \033[3m
mb_colour_m_underline = \033[4m
mb_colour_m_blinking = \033[5m
mb_colour_m_reverse = \033[7m
mb_colour_m_invisible = \033[7m
mb_colour_m_strikeout = \033[9m

define mb_colour_text
$(strip
$(eval mb_colour_text_colour := $(if $(value mb_colour_$1),$(strip $(mb_colour_$1)),$(error ERROR: Undefine colour $1)))
$(mb_colour_text_colour)$2$(mb_colour_reset)
)
endef

endif # __MB_CORE_UTIL_COLOURS_MK__
