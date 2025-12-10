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
