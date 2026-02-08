---
name: find-task
description: Surgically retrieves the most recent status entry for a specific Task ID from the transactional ledger.
---

# Skill: Find Task

This skill allows agents to verify the current state of a specific task without reading the entire ledger file into context.

## Usage

Run the internal script with a Task ID:
`bash .github/skills/find-task/find-task.sh [TASK_ID]`

## Operational Logic

1. Uses `grep` to find all entries for the provided ID in `docs/current/task-status.jsonl`.
2. Uses `tail -n 1` to isolate the most recent state change.
3. Returns the raw JSON line representing the current status.
