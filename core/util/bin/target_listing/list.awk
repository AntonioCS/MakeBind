# Format and display makefile targets with their descriptions
# Input: Lines from targets-filtered file (target:description pairs)
# Output: Colored terminal output with properly aligned target names and descriptions
# Variables passed via -v:
#   SPACING - column width for target name alignment (e.g., 20)

BEGIN {
    # Set field separator to ":.*## " which extracts target and description
    FS = ":.*## "
}

{
    target = $1
    description = $2

    # Default placeholder for parameterized targets
    # This will be replaced if a parameter is found in the description
    placeholder = "<param>"

    # Check if description contains a parameter hint like <database_name>
    # If found, extract it and use it as the placeholder
    if (match(description, /<([^>]+)>/, arr)) {
        placeholder = "<" arr[1] ">"
    }

    # Replace any % symbols in the target name with the extracted placeholder
    # This allows targets like "db/migrate-%" to display as "db/migrate-<version>"
    gsub(/%/, placeholder, target)

    # Print with ANSI color codes for cyan text and proper column alignment
    # \033[36m = cyan color
    # \033[0m = reset formatting
    # %-SPACING s = left-aligned string padded to SPACING width
    printf "\033[36m%-" SPACING "s\033[0m %s\n", target, description
}