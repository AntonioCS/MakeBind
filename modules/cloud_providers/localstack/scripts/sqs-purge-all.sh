#!/usr/bin/env bash
#####################################################################################
# sqs-purge-all.sh
# Purge all SQS queues in LocalStack
#
# Usage: sqs-purge-all.sh <endpoint_url> <region>
#
# Arguments:
#   endpoint_url  - LocalStack endpoint (e.g., http://localhost:4566)
#   region        - AWS region (e.g., eu-west-1)
#
# Prerequisites:
#   - aws CLI installed and on PATH
#   - LocalStack running and accessible
#
# WARNING: This will delete all messages from all queues!
#####################################################################################

set -euo pipefail

readonly ENDPOINT_URL="${1:?Usage: $0 <endpoint_url> <region>}"
readonly REGION="${2:?Usage: $0 <endpoint_url> <region>}"

aws_cmd() {
    aws --endpoint-url "$ENDPOINT_URL" --region "$REGION" "$@"
}

echo "WARNING: Purging all SQS queues..."

queue_urls=$(aws_cmd sqs list-queues --query "QueueUrls[]" --output text 2>/dev/null || echo "")

if [[ -z "$queue_urls" ]]; then
    echo "No queues found"
    exit 0
fi

for url in $queue_urls; do
    echo "  Purging: $url"
    aws_cmd sqs purge-queue --queue-url "$url" 2>/dev/null || true
done

echo "Done"
