## [2.2.10] - 2026-01-06

### Fixed
- **LocalStack `localstack/s3/list-all` and `localstack/sqs/purge-all` syntax error**: Using `$(foreach)` in recipes with `.ONESHELL` caused bash syntax errors due to multi-line output from `mb_invoke`
  - Moved iteration logic to external shell scripts for cleaner execution

### Changed
- **`localstack/s3/list-all` improved output**: Now displays buckets and objects in a tree view with human-readable file sizes and timestamps

### Added
- **LocalStack scripts folder**: `modules/cloud_providers/localstack/scripts/`
  - `s3-list-all.sh` - Lists all S3 buckets and their contents in tree format
  - `sqs-purge-all.sh` - Purges all SQS queues

## [2.2.9] - 2026-01-04

### Fixed
- **PHP staged targets broken in docker mode**: `php/phpcs/staged`, `php/phpstan/staged`, `php/psalm/staged` were not working with docker/docker-compose execution modes
  - **Issue 1**: `mb_run_on_staged` appended files outside docker shell quotes, so files were passed to shell instead of the tool
  - **Issue 2**: Git staged file paths are relative to repo root, but container may mount a subdirectory
  - **Fix**: New `php_run_on_staged` helper gets staged files and passes them inside the invoke call

### Added
- **`mb_staged_strip_prefix` config** (in `core/util/git.mk`): Global config to strip path prefix from staged files
  - Example: Set `mb_staged_strip_prefix := app/` if your code is in `app/` folder mounted as `/app` in container
- **`php_run_on_staged` helper** (in `modules/php/php/php.mk`): Run PHP tools on staged files with proper docker support
  - Usage: `$(call php_run_on_staged,vendor/bin/phpcs -s)`
- **`mb_staged_files` now supports prefix stripping**: Pass optional second argument or use global `mb_staged_strip_prefix`

## [2.2.8] - 2026-01-04

### Added
- **PostgreSQL module**: Complete rewrite with feature-based architecture
  - **Feature system**: Enable only the features you need via `pg_features` variable
  - Available features: `core`, `sql`, `db`, `role`, `conn`, `session`, `dump`, `extension`, `table`, `index`, `maintenance`
  - Default features: `core sql db dump maintenance`
  - **Execution mode support** via `pg_invoke` wrapper function:
    - `local`: Direct binary execution on host
    - `docker`: Run via `docker exec` in `pg_dk_container`
    - `docker-compose`: Run via `docker compose exec` in `pg_dc_service`
  - **New targets**:
    - Connection monitoring: `pg/conn/list`, `pg/conn/count`, `pg/conn/long-running`
    - Session management: `pg/session/kill/%`, `pg/session/kill-idle`, `pg/session/cancel/%`
    - Extension management: `pg/extension/list`, `pg/extension/available`, `pg/extension/create/%`, `pg/extension/drop/%`
    - Index management: `pg/index/list`, `pg/index/unused`, `pg/index/reindex`, `pg/index/reindex/%`
    - Additional: `pg/dump/info`, `pg/table/stats`, `pg/vacuum/%`, `pg/analyze`, `pg/bloat`
  - Configuration via `mod_config.mk` with sensible defaults
  - Tests for configuration, command building, and feature loading
- **`mb_exec_with_mode` enhancements**:
  - Added `<prefix>_env` support to all mode handlers for passing environment variables
  - Improved documentation explaining extensibility and how to create custom mode handlers
  - Handlers (`mb_exec_with_mode_local`, `mb_exec_with_mode_docker`, `mb_exec_with_mode_docker-compose`) now automatically prepend `<prefix>_env` to commands

## [2.2.7] - 2026-01-04

### Added
- **PHPStan module**: New standalone module for PHPStan static analysis
  - `php/phpstan/analyse` - Run PHPStan analysis
  - `php/phpstan/staged` - Run PHPStan on staged PHP files only
  - Configuration options: `phpstan_level`, `phpstan_memory_limit`
  - Runtime variables: `phpstan_files=` for paths, `phpstan_args=` for extra options
  - Depends on `php` module
- **Psalm module**: New standalone module for Psalm static analysis
  - `php/psalm/analyse` - Run Psalm analysis
  - `php/psalm/staged` - Run Psalm on staged PHP files only
  - Configuration options: `psalm_threads`
  - Runtime variables: `psalm_files=` for paths, `psalm_args=` for extra options
  - Depends on `php` module

### Changed
- **PHP module**: Removed old `php/phpstan` and `php/psalm` targets (now in separate modules)

## [2.2.6] - 2026-01-03

### Added
- **PHP CodeSniffer module**: New standalone module for PHP_CodeSniffer
  - `php/phpcs/check` - Run PHP CodeSniffer to detect coding standard violations
  - `php/phpcs/fix` - Run PHP Code Beautifier to auto-fix violations
  - `php/phpcs/staged` - Run PHP CodeSniffer on staged PHP files only
  - Configuration options: `phpcs_parallel`, `phpcs_cache`, `phpcs_progress`, `phpcs_report`
  - Runtime variables: `phpcs_files=` for paths, `phpcs_args=` for extra options
  - Depends on `php` module

### Changed
- **PHP module**: Removed old `php/phpcs` and `php/phpcbf` targets (now in separate phpcs module)
- **Documentation**: Added pitfall about `##` comments in `define...endef` blocks being literal text

## [2.2.5] - 2025-12-26

### Added
- **Docker module**: Network management targets
  - `docker/network/create/<name>` - Create a network (fails if exists)
  - `docker/network/ensure/<name>` - Create network if it doesn't exist (idempotent)
  - `docker/network/remove/<name>` - Remove a network (fails if doesn't exist)
  - Flexible configuration via target parameters or variables:
    - Target format: `<name>[@driver][@subnet][@gateway]`
    - Variable format: `docker_network_<name>_driver`, `docker_network_<name>_subnet`, `docker_network_<name>_gateway`
  - `docker_network_ignore_errors` variable to suppress errors silently
  - `dk_network_default_driver` config (default: bridge)
  - Helper functions: `dk_network_parse_params`, `dk_network_create`, `dk_network_remove`

## [2.2.4] - 2025-12-15

### Added
- **Docker Compose module**: New `dc/pull` target to pull latest images for all services

## [2.2.3] - 2025-12-15

### Fixed
- **Target listing**: Fix duplicate targets appearing after bind-hub restructure (v2.1.1)
  - Added `%/project.mk` and `%/config.mk` to filter-out patterns
  - Previously `project.mk` was included in both project files and other bind-hub files

## [2.2.2] - 2025-12-15

### Changed
- **Terraform module**: Refactored to use `tf_no_var_file_cmds` config list instead of `skip_vars` parameter
  - New `tf_no_var_file_cmds` variable (default: `init validate output state`)
  - `tf_run` automatically skips `-var-file` for commands in the list
  - Use `mb_is_true` for boolean checks instead of `$(filter $(mb_true),...)`

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
