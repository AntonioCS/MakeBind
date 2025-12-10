{
    # Skip documentation annotation lines (## @var, ## @desc, ## @type, etc.)
    if ($0 ~ /^[[:space:]]*##[[:space:]]*@/) {
        next
    }

    # Replace ?= with :=
    gsub(/\?=/, ":=")

    # Add # only if line is not blank and doesn't already start with #
    if ($0 !~ /^[[:space:]]*$/ && $0 !~ /^#/) {
        print "#" $0
    } else {
        print $0
    }
}