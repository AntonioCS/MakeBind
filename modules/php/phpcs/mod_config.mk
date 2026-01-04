## Path to PHP CodeSniffer binary
phpcs_bin ?= vendor/bin/phpcs#

## Path to PHP Code Beautifier and Fixer binary
phpcbf_bin ?= vendor/bin/phpcbf#

## Path to phpcs configuration file
phpcs_config_file ?= phpcs.xml#

## If true, send check output to file instead of stdout
phpcs_send_to_file ?= $(mb_true)#

## Output file for phpcs check results
phpcs_output_file ?= phpcs.output#

## Number of parallel processes (requires PCNTL extension, 1 = sequential)
phpcs_parallel ?=#

## Enable caching (empty = no cache, or path to cache file)
phpcs_cache ?=#

## Show progress dots during check
phpcs_progress ?=#

## Report format (full, json, checkstyle, junit, summary, etc.)
phpcs_report ?=#
