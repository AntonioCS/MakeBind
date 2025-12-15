## [2.2.1] - 2025-12-15

### Fixed
- **Terraform module**: Added `skip_vars` parameter to `tf_run` function for commands that don't support `-var-file`
  - Commands that now correctly skip `-var-file`: `init`, `validate`, `output`, `state list`
  - New test: `test_modules_terraform_run_skip_vars`

## [2.2.0] - 2025-12-15

### Added
- **Terraform module**: New workflow automation for multi-environment Terraform deployments
  - `tf_run` function for executing terraform commands with automatic shared vars inclusion
  - `tf_build_chdir`, `tf_build_var_file`, `tf_is_auto_approve_env` helper functions
  - Pattern targets: `terraform/init/%`, `terraform/plan/%`, `terraform/apply/%`, `terraform/destroy/%`, `terraform/validate/%`, `terraform/output/%`, `terraform/state/list/%`, `terraform/refresh/%`
  - Utility targets: `terraform/fmt`, `terraform/fmt/check`, `terraform/version`
  - Configuration: `tf_bin`, `tf_root_dir`, `tf_env_dir`, `tf_shared_vars` (multi-file support), `tf_auto_approve_envs`, `tf_destroy_confirm`, `tf_chdir_flag`
  - Comprehensive test suite (15 tests, 36 assertions)
- **LocalStack module enhancements**:
  - `localstack/s3/ls` target with optional `bucket=` parameter
  - `localstack/sqs/ls` target for listing queues
  - Comprehensive test suite (11 tests, 26 assertions)

## [2.1.1] - 2025-12-10

### Changed
- **bind-hub folder restructure**: Simplified file naming and improved organization
  - Renamed user-editable files to remove `mb_` prefix:
    - `mb_config.mk` → `config.mk`
    - `mb_project.mk` → `project.mk`
    - `mb_config.local.mk` → `config.local.mk`
    - `mb_project.local.mk` → `project.local.mk`
  - Moved auto-generated modules file to `internal/` subfolder:
    - `mb_modules.mk` → `internal/modules.mk`
  - Updated internal variable names for consistency:
    - `mb_project_bindhub_modules_file` → `mb_project_bindhub_internal_modules_file`
  - Template files renamed to match new convention (`config.tpl.mk`, `project.tpl.mk`)

### Added
- **Deprecation detection**: Projects using old bind-hub structure (pre-2.1.1) will now fail with migration instructions
- `core/deprecation.mk`: New file containing deprecation checks and error messages
- `templates/README.bind-hub.md`: README template for new bind-hub folders explaining structure

### Fixed
- Improved clarity of bind-hub folder organization (user files vs auto-generated files)

## [2.1.0] - 2025-12-10

### Added
- **LocalStack module**: New AWS emulation wrapper for local development
  - `localstack_cmd` function for AWS CLI commands against LocalStack
  - `localstack_api`, `localstack_api_check`, `localstack_api_json` for LocalStack API access
  - Targets: `localstack/health`, `localstack/status`, `localstack/shell`, `localstack/diagnostics`, `localstack/version`
  - Magic redirect pattern: `localstack/aws/%` delegates to AWS module with LocalStack endpoint
  - Convenience targets: `localstack/s3/list-all`, `localstack/sqs/purge-all`
- **`mb_exec_with_mode` function**: Generic execution mode system (local/docker/docker-compose)
  - Dispatch pattern for mode handlers
  - Docker module provides `mb_exec_with_mode_docker` handler
  - Docker-compose module provides `mb_exec_with_mode_docker-compose` handler
- **Test framework rewrite**:
  - New `test_runner.mk` with auto-discovery of `*_test.mk` files
  - New `asserts.mk` with expanded assertion functions (`mb_assert_empty`, `mb_assert_not_empty`, `mb_assert_filter`, `mb_assert_contains`, `mb_assert_exists`, `mb_assert_not_exists`)
  - Tests now use `define test_<name>` pattern instead of targets
  - Added `tests/README.md` documentation
- Docker module tests (`docker_test.mk`)
- `mb_exec_with_mode` tests

### Changed
- **Docker module refactored**: Split into `functions.mk` and `targets.mk` for better organization
- **AWS module**: Renamed variables from `mb_aws_*` to `aws_*` for consistency
- **PHP modules** (php, phpunit, composer, symfony, laravel, doctrine): Updated to use `mb_exec_with_mode` pattern
- Improved module loading mechanism with config file support for dependencies and load order

### Removed
- All `.PHONY` declarations from modules (redundant due to `--always-make` flag)

### Fixed
- S3 module: Fixed `$(mb_aws_bin)` → `$(aws_bin)` in `aws/s3/key-delete/%` target
- AWS module: Updated outdated variable names in documentation comments
- Tests: Merged orphaned `util_test_mb_is_regex_match.mk` tests into `util_test.mk`
- Tests: Cleaned up unused files (`empty.mk`, `data/test_module.mk`)

## [2.0.1] - 2025-04-13

### Fixed
- undefined variable 'mb_ask_user_text'
- calling wrong function mb_print_info (missing f in print, should be printf)

## [2.0.0] - 2025-03-22

### Changed
- Refactored the module system: file paths are no longer accepted — only module names are supported now.  
  ⚠️ **This is a breaking change** if you're using direct file paths.

### Added
- `CHANGELOG.md` file to track project changes going forward

### Fixed
- Various small bugs

## [1.0.0] - 2024-07-26

### Added
- Improved Windows support
- Various bug fixes

## [0.0.1] - 2024-06-20
- Initial release
