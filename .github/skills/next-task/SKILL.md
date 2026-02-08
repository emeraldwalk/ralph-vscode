---
name: next-task
description: Logic to identify the single next unclaimed and ready task ID from the backlog.
---

# Skill: Next Task

This skill provides the Orchestrator with the specific ID of the next executable task.

## Usage

Run the internal script to retrieve the ID:
`bash .github/skills/next-task/next-task.sh`

## Operational Logic

- Scans `docs/tasks/T-*.json`.
- Filters out IDs already in `docs/current/task-status.jsonl`.
- Verifies all `requires` dependencies are marked `completed` in the ledger.
- Returns the first valid ID.
