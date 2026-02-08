#!/bin/bash
# Usage: bash .github/skills/find-task/find-task.sh T-001
grep "\"id\": \"$1\"" docs/current/task-status.jsonl | tail -n 1
