#!/bin/bash
# Usage: bash .github/skills/next-task/next-task.sh [--skip-failed]
# Outputs: TASK_ID STATUS (e.g. "T-003 failed" or "T-005 new")
# --skip-failed: Skip tasks whose latest status is "failed" or "claimed" (stale).

skip_failed=false
if [ "$1" = "--skip-failed" ]; then
    skip_failed=true
fi

for task_file in docs/tasks/T-*.json; do
    id=$(basename "$task_file" .json)

    # Get the most recent status entry for this task
    latest=$(grep "\"id\": \"$id\"" docs/current/task-status.jsonl | tail -n 1)

    # Determine current status
    if [ -z "$latest" ]; then
        status="new"
    elif echo "$latest" | grep -q '"status": "completed"'; then
        continue
    elif echo "$latest" | grep -q '"status": "claimed"'; then
        status="claimed"
    elif echo "$latest" | grep -q '"status": "failed"'; then
        status="failed"
    else
        status="unknown"
    fi

    # Skip failed/claimed tasks if flag is set
    if [ "$skip_failed" = true ] && [ "$status" = "failed" -o "$status" = "claimed" ]; then
        continue
    fi

    # Check dependencies
    deps=$(jq -r '.requires[]' "$task_file" 2>/dev/null)
    ready=true
    for dep in $deps; do
        if ! grep -q "\"id\": \"$dep\", \"status\": \"completed\"" docs/current/task-status.jsonl; then
            ready=false; break
        fi
    done

    if [ "$ready" = true ]; then
        echo "$id $status"
        exit 0
    fi
done
exit 1
