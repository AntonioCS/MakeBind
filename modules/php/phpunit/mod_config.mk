
## Path to PHPUnit binary
phpunit_bin ?= vendor/bin/phpunit#

## If true, remove PHP max_execution_time (use -d max_execution_time=0)
phpunit_remove_max_execution_time ?= $(mb_true)#

## If true, stop on first failed assertion (--stop-on-failure)
phpunit_stop_on_failure ?= $(mb_true)#

## If true, stop when an error occurs (--stop-on-error)
phpunit_stop_on_error ?= $(mb_true)#

