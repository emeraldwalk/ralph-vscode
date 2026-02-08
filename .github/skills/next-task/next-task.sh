#!/bin/bash
# Logic: Find the first T-XXX.json that isn't in the ledger and has all deps completed.
for task_file in docs/tasks/T-*.json; do
    id=$(basename "$task_file" .json)

    # Skip if already claimed/completed in the ledger
    if grep -q "\"id\": \"$id\"" docs/current/task-status.jsonl; then continue; fi

    # Check dependencies
    deps=$(jq -r '.requires[]' "$task_file" 2>/dev/null)
    ready=true
    for dep in $deps; do
        if ! grep -q "\"id\": \"$dep\", \"status\": \"completed\"" docs/current/task-status.jsonl; then
            ready=false; break
        fi
    done

    if [ "$ready" = true ]; then
        echo "$id"
        exit 0
    fi
done
exit 1
