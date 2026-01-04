## Path to Psalm binary
psalm_bin ?= vendor/bin/psalm#

## Path to psalm configuration file
psalm_config ?= psalm.xml#

## Number of threads to use (empty = use default)
psalm_threads ?=#

## If true, send output to file instead of stdout
psalm_send_to_file ?= $(mb_true)#

## Output file for psalm results
psalm_output_file ?= psalm.output#
