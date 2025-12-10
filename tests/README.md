# MakeBind Test Framework

## Running Tests

```bash
cd tests

# Run all tests (auto-discovers from tests/unit/ and modules/)
make

# Run specific module/file tests
make test=docker
make test=cache

# Filter which test functions to run
make filter=test_mb_invoke

# Exclude specific test functions
make exclude=test_slow_operation

# Add custom search paths
make mb_test_search_paths="/path/to/extra/tests"
```

## Architecture

### Entry Point

`tests/Makefile` is the main test runner. It:

1. Sets up paths (`mb_test_path`, `mb_core_path`, `mb_modules_path`)
2. Includes `test_runner.mk` (the test engine)
3. Includes test files from `unit/core/`
4. Provides `run_tests` and `discover` targets

### Test Runner (`test_runner.mk`)

The test engine provides:

- **Test discovery**: `mb_test_find_all_tests` finds all `*_test.mk` files
- **Test loading**: `mb_test_load_tests` dynamically includes test files
- **Test execution**: `mb_run_tests` iterates over `test_*` variables and calls them
- **Function mocking**: `mb_assert_was_called` tracks function invocations

### Assertions (`asserts.mk`)

| Function | Description | Example |
|----------|-------------|---------|
| `mb_assert` | Assert truthy condition | `$(call mb_assert,$(value foo),foo should be set)` |
| `mb_assert_eq` | Assert equality | `$(call mb_assert_eq,expected,$(actual))` |
| `mb_assert_neq` | Assert inequality | `$(call mb_assert_neq,bad_value,$(actual))` |
| `mb_assert_empty` | Assert empty value | `$(call mb_assert_empty,$(result))` |
| `mb_assert_not_empty` | Assert non-empty | `$(call mb_assert_not_empty,$(result))` |
| `mb_assert_filter` | Assert pattern match (% at start/end only) | `$(call mb_assert_filter,%.mk,$(filename))` |
| `mb_assert_contains` | Assert substring found | `$(call mb_assert_contains,error,$(output))` |
| `mb_assert_exists` | Assert file exists | `$(call mb_assert_exists,/path/to/file)` |
| `mb_assert_not_exists` | Assert file missing | `$(call mb_assert_not_exists,/tmp/should_not_exist)` |

All assertions accept an optional final argument for a custom failure message.

## Writing Tests

### Test File Structure

Test files must:
- Be named `*_test.mk`
- Define tests as `define test_<name>` blocks (NOT targets)
- Include required dependencies

```makefile
# tests/unit/core/my_feature_test.mk

include $(mb_core_path)/functions.mk

define test_my_feature_basic
    $(eval result := $(call my_function,arg1))
    $(call mb_assert_eq,expected_value,$(result))
endef

define test_my_feature_edge_case
    $(call mb_assert_empty,$(call my_function,))
endef
```

### Test Naming Convention

- Prefix with `test_`
- Use descriptive names: `test_mb_invoke_dry_run_on`
- Group related tests with common prefix: `test_docker_*`

### Test Isolation

Tests run sequentially and share state. Reset modified globals:

```makefile
define test_mb_invoke_silent_on
    ## Set test state
    $(eval mb_invoke_silent := $(mb_on))

    ## Run test
    $(eval result := $(call mb_invoke,echo hello))
    $(call mb_assert_empty,$(result))

    ## Restore state for next test
    $(eval mb_invoke_silent := $(mb_off))
endef
```

### Function Call Tracking

Use `mb_assert_was_called` to verify function invocations:

```makefile
define test_prints_info_message
    $(call mb_assert_was_called,mb_printf_info,2)
    $(call some_function_that_should_print_twice)
endef
```

## Directory Structure

```
tests/
├── Makefile           # Entry point
├── test_runner.mk     # Test engine (discovery, execution)
├── asserts.mk         # Assertion functions
├── mb_config.test.mk  # Test configuration overrides
├── data/              # Test fixtures
├── mock_project/      # Mock project for integration tests
└── unit/
    └── core/
        ├── mb_invoke_test.mk
        ├── util_test.mk
        ├── util/
        │   ├── cache_test.mk
        │   └── help_test.mk
        └── modules_manager_test.mk
```

## Module Tests

Modules can include tests in their directory as `<module>_test.mk`:

```
modules/containers/docker/
├── docker.mk
├── functions.mk
├── targets.mk
├── mod_config.mk
├── mod_info.mk
└── docker_test.mk    # Module tests
```

Module tests are discovered with:

```bash
make discover test=docker
```

### Dynamic Loading and Targets

Test discovery uses `$(eval include ...)` which cannot define Make targets. Files with targets must wrap them:

```makefile
## Skip target definitions when loaded dynamically
ifndef __MB_TEST_DISCOVERY__

my/target: ## My target
    @echo "Hello"

endif # __MB_TEST_DISCOVERY__
```

The test runner sets `__MB_TEST_DISCOVERY__` before loading test files.

### Module Test Files

Module tests should include only what they need:

```makefile
# Good - include only functions (targets are guarded)
include $(mb_modules_path)/containers/docker/mod_config.mk
include $(mb_modules_path)/containers/docker/functions.mk

# Also works if targets are wrapped with ifndef __MB_TEST_DISCOVERY__
include $(mb_core_path)/util/cache.mk
```
