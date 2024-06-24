mb_has_main_mk := $(mb_test_path)/empty.mk
MB_DOWNLOAD_LATEST_MB := 1
include mock_project/Makefile

mb_mb_default_path := $(abspath $(mb_test_path)/../tmp/)
mb_test_expected_mb_folder := $(mb_mb_default_path)/MakeBind

tests/Makfile_test:
	$(call mb_zip_path_generate)
	$(call mb_assert_eq,$(mb_zip_path),/tmp/mb.zip,mb_zip_path_generate generates the correct path)
	$(call mb_latest_release_url_generate)
	$(call mb_assert_filter, https://api.github.com/repos/AntonioCS/MakeBind/zipball/v%,$(mb_latest_releate_url),mb_latest_release_url_generate generates the correct url)
	$(call mb_download_latest_mb)
	$(call mb_assert_exists,$(mb_zip_path))
	$(call mb_install)
	$(call mb_assert_exists,$(mb_test_expected_mb_folder))
ifeq ($(OS),Windows_NT)
	powershell -Command "Remove-Item -Recurse -Force '$(mb_test_expected_mb_folder)'"
else
	rm -rf $(mb_test_expected_mb_folder)
endif
