
include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk
include $(mb_modules_path)/docker/docker_compose.mk

define __test_modules_docker_compose_setup
	$(eval mb_invoke_silent := $(mb_on))
	$(eval dc_files := docker_compose_file.yml)
endef

define __test_modules_docker_compose_teardown
	$(eval mb_invoke_silent := $(mb_off))
	$(eval dc_files := $(mb_empty))
endef

define test_modules_docker_compose_dc_invoke
	$(eval mb_invoke_silent := $(mb_on))
	$(eval dc_files := docker_compose_file.yml)
	$(eval $0_dc_service_name := serviceA)
	$(eval $0_expected_start := docker compose --file $(dc_files))

	## Passing just the command
	$(eval $0_expected_0 := $($0_expected_start) up)
	$(eval $0_result_0 := $(call dc_invoke,up))
	$(eval $0_expected_1 := $($0_expected_start) stop)
	$(eval $0_result_1 := $(call dc_invoke,stop))

	## Using options
	$(eval $0_expected_2 := $($0_expected_start) down --volumes)
	$(eval $0_result_2 := $(call dc_invoke,down,--volumes))

	## Passing service name only
	$(eval $0_expected_3 := $($0_expected_start) down $($0_dc_service_name))
	$(eval $0_result_3 := $(call dc_invoke,down,,$($0_dc_service_name)))

	## Passing service name with options
	$(eval $0_expected_4 := $($0_expected_start) down --volumes $($0_dc_service_name))
	$(eval $0_result_4 := $(call dc_invoke,down,--volumes,$($0_dc_service_name)))

	## Using extra
	$(eval $0_expected_5 := $($0_expected_start) exec $($0_dc_service_name) bash)
	$(eval $0_result_5 := $(call dc_invoke,exec,,$($0_dc_service_name),bash))

	$(foreach i,0 1 2 3 4 5,\
		$(call mb_assert_eq,$($0_expected_$i),$($0_result_$i))\
	)

	$(eval mb_invoke_silent := $(mb_off))
endef

define test_modules_docker_compose_dc_invoke_using_command_variables
	$(eval mb_invoke_silent := $(mb_on))
	$(eval $0_dc_service_name := serviceA)
	$(eval $0_dc_test_cmd := up)
	$(eval dc_files := docker_compose_file.yml)
	$(eval $0_expected_start := docker compose --file $(dc_files))

	$(eval $0_services := serviceA)
	$(eval dc_cmd_services_$($0_dc_test_cmd) := $($0_services))
	$(eval $0_expected := $($0_expected_start) $($0_dc_test_cmd) $($0_services))
	$(eval $0_result := $(call dc_invoke,$($0_dc_test_cmd)))
	$(call mb_assert_eq,$($0_expected),$($0_result))
	$(eval undefine dc_cmd_services_$($0_dc_test_cmd))

	$(eval $0_options := --build)
	$(eval dc_cmd_options_$($0_dc_test_cmd) := $($0_options))
	$(eval $0_expected := $($0_expected_start) $($0_dc_test_cmd) $($0_options))
	$(eval $0_result := $(call dc_invoke,$($0_dc_test_cmd)))
	$(call mb_assert_eq,$($0_expected),$($0_result))
	$(eval undefine dc_cmd_options_$($0_dc_test_cmd))

	$(eval $0_extras := --no-really-used-in-up)
	$(eval dc_cmd_extas_$($0_dc_test_cmd) := $($0_extras))

	### Check for correct order
	$(eval dc_cmd_services_$($0_dc_test_cmd) := $($0_services))
	$(eval dc_cmd_options_$($0_dc_test_cmd) := $($0_options))
	$(eval $0_expected := $($0_expected_start) $($0_dc_test_cmd) $($0_options) $($0_services))
	$(eval $0_result := $(call dc_invoke,$($0_dc_test_cmd)))
	$(call mb_assert_eq,$($0_expected),$($0_result))
	$(eval undefine dc_cmd_services_$($0_dc_test_cmd))
	$(eval undefine dc_cmd_options_$($0_dc_test_cmd))

	$(eval undefine dc_files)
	$(eval mb_invoke_silent := $(mb_off))
endef

#	$(eval $0_all_targets := dc/up dc/start dc/stop \
#		dc/down dc/logs dc/status dc/status-all\
#	)



### Remove the timestamp, project name and the word Executing: from output given
docker_test_helper_normalize_output = $(wordlist 4,$(words $(strip $1)),$(strip $1))
docker_test_help_fetch_line = $(call docker_test_helper_normalize_output,$(shell sed -n '$1{p;q}' $2))

## Note: Need to add GNUMAKEFLAGS to the cli_vars because I get an error if I don't
define test_modules_docker_compose_targets

	$(eval $0_dc_file := docker_compose_file.yml)
	$(eval $0_cli_vars := mb_invoke_print_target=$(mb_off) \
			mb_invoke_dry_run=$(mb_on) \
			dc_files=$($0_dc_file) \
			GNUMAKEFLAGS=0\
	)
	$(eval $0_expected_start := docker compose --file $($0_dc_file))

	$(eval $0_single_targets := dc/up dc/stop dc/down dc/status dc/status-all dc/build dc/stats)
	### $($0_expected_start) must be added to the expected output
	$(eval
		$0_expected_dc/up := up --remove-orphans -d --wait
		$0_expected_dc/stop := stop
		$0_expected_dc/down := down
		$0_expected_dc/status := ps --no-trunc
		$0_expected_dc/status-all := ps --no-trunc --all
		$0_expected_dc/build := build --parallel $(dc_build_args_linux_mac)
		$0_expected_dc/stats := stats)
	)

	### We must process the output to remove the timestamp, project name and the word Executing:
	$(foreach $0_running_target,$($0_single_targets),
		$(if $(mb_debug_tests),$(info Running target: $($0_running_target)))
		$(eval $0_expected := $($0_expected_$($0_running_target)))
		$(eval $0_output := $(shell $(MAKE) $($0_running_target) $($0_cli_vars)))
		$(if $(mb_debug_tests),$(info Ouput: $($0_output)))
		$(eval $0_result := $(call docker_test_helper_normalize_output, $($0_output)))
		$(call mb_assert_eq,$($0_expected_start) $($0_expected),$($0_result))
	)

	### Compount targets
	$(eval $0_output_file := /tmp/mb_test_output)

	$(shell $(MAKE) dc/rebuild $($0_cli_vars) > $($0_output_file))
	### Expect 3 lines
	$(eval $0_output_0 := $(call docker_test_help_fetch_line,1,$($0_output_file)))
	$(eval $0_output_1 := $(call docker_test_help_fetch_line,2,$($0_output_file)))
	$(eval $0_output_2 := $(call docker_test_help_fetch_line,3,$($0_output_file)))
	$(call mb_assert_eq,$($0_expected_start) $($0_expected_dc/stop), $($0_output_0))
	$(call mb_assert_eq,$($0_expected_start) $($0_expected_dc/build) --no-cache, $($0_output_1))
	$(call mb_assert_eq,$($0_expected_start) $($0_expected_dc/up), $($0_output_2))

	$(shell $(MAKE) dc/restart $($0_cli_vars) > $($0_output_file))
	### Expect 2 lines
	$(eval $0_output_0 := $(call docker_test_help_fetch_line,1,$($0_output_file)))
	$(eval $0_output_1 := $(call docker_test_help_fetch_line,2,$($0_output_file)))
	$(call mb_assert_eq,$($0_expected_start) $($0_expected_dc/stop), $($0_output_0))
    $(call mb_assert_eq,$($0_expected_start) $($0_expected_dc/up), $($0_output_1))
endef
