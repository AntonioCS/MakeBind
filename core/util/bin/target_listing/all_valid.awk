# Extract all valid make target names from make's database output
# Input: Output from "make -pRrn" which dumps the make database
# Output: Sorted list of valid target names (one per line)
#
# Pattern explanation:
# ^[^.#\/[:space:]]  = line doesn't start with . # / or whitespace
# [^=]*              = target name (anything except =)
# :([^=]|$)          = colon followed by either non-= or end of line
#
# This filters out variables (which contain =) and special make rules

# Match lines that represent actual targets (not variables or special rules)
/^[^.#\/[:space:]][^=]*:([^=]|$)/ {
    # Extract just the target name (everything before the colon)
    target = $1
    # Store in array for sorting
    targets[target]
}

END {
    # Sort targets alphabetically before output
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (target in targets) {
        print target
    }
}