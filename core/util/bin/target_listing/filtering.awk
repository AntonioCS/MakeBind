# Filter documented targets by checking against list of all valid targets
# This script reads two files:
#   1. targets-valid: list of all make targets (one per line)
#   2. targets-desc: all targets that have documentation comments
# Output: Only targets that are both valid AND have documentation

BEGIN {
    FS = ":"
}

# First pass: read all valid target names from first file into associative array
# NR==FNR checks if we're still reading the first input file
NR == FNR {
    # Store each target name as a key (value doesn't matter, we just check key existence)
    targets[$1]
    next
}

# Second pass: check if each documented target exists in our valid targets list
# Only print lines where the target (first field) was in our valid targets array
$1 in targets