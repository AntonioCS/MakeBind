
include $(mb_test_path)/../core/util/colours.mk



tests/core/util/mb_colour_text_test:
	printf "%b\n" "a $(call mb_colour_text,Green,mb_colour_text tests passed)"