#!/usr/bin/env bash
#####################################################################################
# s3-list-all.sh
# List all S3 buckets and their contents from LocalStack (tree view)
#
# Usage: s3-list-all.sh <endpoint_url> <region>
#
# Arguments:
#   endpoint_url  - LocalStack endpoint (e.g., http://localhost:4566)
#   region        - AWS region (e.g., eu-west-1)
#
# Prerequisites:
#   - aws CLI installed and on PATH
#   - LocalStack running and accessible
#####################################################################################

set -euo pipefail

readonly ENDPOINT_URL="${1:?Usage: $0 <endpoint_url> <region>}"
readonly REGION="${2:?Usage: $0 <endpoint_url> <region>}"

aws_cmd() {
    aws --endpoint-url "$ENDPOINT_URL" --region "$REGION" "$@"
}

human_size() {
    local bytes=$1
    if [[ $bytes -ge 1073741824 ]]; then
        printf "%.1f GB" "$(echo "scale=1; $bytes / 1073741824" | bc)"
    elif [[ $bytes -ge 1048576 ]]; then
        printf "%.1f MB" "$(echo "scale=1; $bytes / 1048576" | bc)"
    elif [[ $bytes -ge 1024 ]]; then
        printf "%.1f KB" "$(echo "scale=1; $bytes / 1024" | bc)"
    else
        printf "%d B" "$bytes"
    fi
}

echo "S3 Buckets:"
echo ""

buckets=$(aws_cmd s3api list-buckets --query "Buckets[].Name" --output text 2>/dev/null || echo "")

if [[ -z "$buckets" ]]; then
    echo "  (no buckets found)"
    exit 0
fi

bucket_array=($buckets)
total_buckets=${#bucket_array[@]}
bucket_index=0

for bucket in "${bucket_array[@]}"; do
    bucket_index=$((bucket_index + 1))
    is_last_bucket=$([[ $bucket_index -eq $total_buckets ]] && echo 1 || echo 0)

    if [[ $is_last_bucket -eq 1 ]]; then
        echo "└── $bucket/"
        prefix="    "
    else
        echo "├── $bucket/"
        prefix="│   "
    fi

    # Get objects in bucket (LastModified, Size, Key)
    objects=$(aws_cmd s3api list-objects-v2 --bucket "$bucket" --query "Contents[].[LastModified,Size,Key]" --output text 2>/dev/null || echo "")

    if [[ -z "$objects" || "$objects" == "None" ]]; then
        echo "${prefix}└── (empty)"
    else
        # Count objects for proper tree formatting
        object_count=$(echo "$objects" | wc -l)
        object_index=0

        while IFS=$'\t' read -r timestamp size key; do
            object_index=$((object_index + 1))
            is_last_object=$([[ $object_index -eq $object_count ]] && echo 1 || echo 0)

            size_human=$(human_size "$size")
            # Format timestamp: 2026-01-06T11:14:41+00:00 -> 2026-01-06 11:14:41
            timestamp_formatted=$(echo "$timestamp" | sed 's/T/ /; s/+.*//')

            if [[ $is_last_object -eq 1 ]]; then
                echo "${prefix}└── $timestamp_formatted  $key ($size_human)"
            else
                echo "${prefix}├── $timestamp_formatted  $key ($size_human)"
            fi
        done <<< "$objects"
    fi
done
