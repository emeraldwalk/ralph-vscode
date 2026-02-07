---
name: available-tasks
description: This skill provides the Orchestrator with a filtered list of executable tasks, abstracting away dependency and status checks.
---

# Skill: Available Tasks

This skill provides the Orchestrator with a filtered list of executable tasks, abstracting away dependency and status checks.

## Capabilities:

- **Get Next Ready**: Returns the single most high-priority `T-XXX.json` that has all its `requires` dependencies marked as `completed` in the ledger.
- **Get Ready Batch (N)**: Returns the next N tasks that are currently unblocked and unclaimed.
- **Check Blockers**: For a specific Task ID, lists exactly which dependency is missing or failed.

## Logic (The "Magic" Query):

To find a ready task, the skill performs this logic internally:

1. List all `docs/tasks/*.json`.
2. Filter out any ID that already has a `claimed` or `completed` entry in `docs/current/task-status.jsonl`.
3. For the remaining candidates, check if every ID in their `requires` array has a `completed` entry in the ledger.

## Rules:

- Only return tasks that are truly executable.
- If no tasks are ready but some are pending, report the specific IDs that are "Blocked."
