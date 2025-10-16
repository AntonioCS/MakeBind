# Target Pattern Documentation

## Overview
Pattern to match makefile targets that have documentation comments. Matches targets followed by `## ` and a description.

## Pattern Breakdown

| Element | Meaning |
|---------|---------|
| `^` | Start of line |
| `[$()/a-zA-Z0-9_%/\-]+` | Valid target name chars (includes: `$`, `()`, `/`, `a-z`, `A-Z`, `0-9`, `_`, `%`, `-`) |
| `:` | Target separator |
| `.*##` | Any characters followed by documentation marker and space |
| `.*$` | Description text to end of line |

## Notes

- ERE (Extended Regular Expressions) doesn't support non-greedy quantifiers, so we use greedy `.*` which still works because we're anchored by the specific `##` pattern

---

<small>**Note:** This documentation is kept in a separate file because `grep -f` treats every line as a distinct regex pattern. Comments in the pattern file would be interpreted as patterns too, causing unintended matches.</small>