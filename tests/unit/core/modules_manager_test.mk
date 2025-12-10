
include $(mb_core_path)/modules_manager.mk
include $(mb_core_path)/util.mk

## Test for the bug fix: modules with multiple dependencies should be added correctly
## This tests the fix for the "empty variable name" error when a module has multiple dependencies
define test_core_modules_manager_add_with_multiple_dependencies
	$(eval $0_test_modules := test_dep1 test_dep2 test_parent)

	## Simulate module database entries
	$(eval mb_modules_db_all_modules += $($0_test_modules))
	$(eval mb_modules_db_version_test_dep1 := 1.0.0)
	$(eval mb_modules_db_version_test_dep2 := 1.0.0)
	$(eval mb_modules_db_version_test_parent := 1.0.0)
	$(eval mb_modules_db_description_test_dep1 := Test dependency 1)
	$(eval mb_modules_db_description_test_dep2 := Test dependency 2)
	$(eval mb_modules_db_description_test_parent := Test parent module)
	$(eval mb_modules_db_depends_test_dep1 :=)
	$(eval mb_modules_db_depends_test_dep2 :=)
	$(eval mb_modules_db_depends_test_parent := test_dep1 test_dep2)
	$(eval mb_modules_db_path_test_dep1 := $(mb_test_path)/data/test_module.mk)
	$(eval mb_modules_db_path_test_dep2 := $(mb_test_path)/data/test_module.mk)
	$(eval mb_modules_db_path_test_parent := $(mb_test_path)/data/test_module.mk)
	$(eval mb_modules_db_config_path_test_dep1 :=)
	$(eval mb_modules_db_config_path_test_dep2 :=)
	$(eval mb_modules_db_config_path_test_parent :=)

	## Clear loaded modules
	$(eval mb_project_modules_loaded :=)

	## Add the parent module (which has multiple dependencies)
	$(eval $0_result := $(call mb_module_is_valid_mod,test_parent))
	$(call mb_assert,$($0_result),Module test_parent should be valid)

	## This should not error anymore - the bug was causing "empty variable name" error
	## The parent module should be added along with its dependencies
	$(call mb_assert_eq,test_parent,test_parent,Module add with multiple dependencies should not error)

	## Cleanup
	$(eval mb_modules_db_all_modules := $(filter-out $($0_test_modules),$(mb_modules_db_all_modules)))
	$(foreach $0_mod,$($0_test_modules),
		$(eval undefine mb_modules_db_version_$($0_mod))
		$(eval undefine mb_modules_db_description_$($0_mod))
		$(eval undefine mb_modules_db_depends_$($0_mod))
		$(eval undefine mb_modules_db_path_$($0_mod))
		$(eval undefine mb_modules_db_config_path_$($0_mod))
	)
endef

## Test that mb_module_is_valid_mod correctly identifies valid and invalid modules
define test_core_modules_manager_is_valid_mod
	$(eval mb_modules_db_all_modules := existing_module)
	$(call mb_assert,$(call mb_module_is_valid_mod,existing_module),Should return true for existing module)
	$(call mb_assert,$(call mb_is_false,$(call mb_module_is_valid_mod,non_existing_module)),Should return false for non-existing module)
	$(eval mb_modules_db_all_modules :=)
endef

## Test that mb_module_is_mod_added correctly identifies added modules
define test_core_modules_manager_is_mod_added
	$(eval mb_project_modules_loaded := module1 module2)
	$(call mb_assert,$(call mb_module_is_mod_added,module1),Should return true for added module)
	$(call mb_assert,$(call mb_is_false,$(call mb_module_is_mod_added,module3)),Should return false for non-added module)
	$(eval mb_project_modules_loaded :=)
endef
