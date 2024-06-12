
include $(mb_test_path)/../core/util.mk
include $(mb_test_path)/../core/functions.mk
include $(mb_test_path)/../modules/docker/docker_compose.mk


tests/modules/docker/docker_compose/dc_invoke: private mb_invoke_silent := $(mb_on)
tests/modules/docker/docker_compose/dc_invoke:
	$(eval result := $(call dc_invoke,up))
	$(call mb_assert_eq,docker compose up,$(result))
	$(eval dc_cmd_services_up := serviceX)
	$(eval result := $(call dc_invoke,up))
	$(call mb_assert_eq,docker compose up serviceX,$(result))
	$(eval dc_cmd_options_up := --build)
	$(eval result := $(call dc_invoke,up))
	$(call mb_assert_eq,docker compose up --build serviceX,$(result))
	$(eval
		undefine dc_cmd_options_up
		undefine dc_cmd_services_up
	)
	$(eval result := $(call dc_invoke,up,--build,serviceY))
	$(call mb_assert_eq,docker compose up --build serviceY,$(result))
#$(info RESULT: $(result))
