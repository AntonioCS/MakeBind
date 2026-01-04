## Path to PHPStan binary
phpstan_bin ?= vendor/bin/phpstan#

## Path to phpstan configuration file
phpstan_config ?= phpstan.neon#

## Analysis level (0-9, empty = use config file setting)
phpstan_level ?=#

## Memory limit (e.g., 512M, 1G)
phpstan_memory_limit ?=#

## If true, send output to file instead of stdout
phpstan_send_to_file ?= $(mb_true)#

## Output file for phpstan results
phpstan_output_file ?= phpstan.output#
