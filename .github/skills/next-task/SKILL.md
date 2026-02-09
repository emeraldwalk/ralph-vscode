---
name: next-task
description: Logic to identify the single next unclaimed and ready task ID from the backlog.
---

# Skill: Next Task

This skill provides the Orchestrator with the specific ID of the next executable task.

## Usage

Run the internal script to retrieve the ID and its status:
`bash .github/skills/next-task/next-task.sh`

To skip failed and stale-claimed tasks:
`bash .github/skills/next-task/next-task.sh --skip-failed`

## Output

Returns a single line: `TASK_ID STATUS` (e.g. `T-003 failed`, `T-005 new`, `T-002 claimed`).

Possible statuses:
- `new` — Task has never been attempted.
- `failed` — Task was attempted and failed.
- `claimed` — Task was claimed by a prior session but never completed or failed (stale).

## Operational Logic

- Scans `docs/tasks/T-*.json`.
- For each task, checks the **most recent** status entry in `docs/current/task-status.jsonl`.
- Skips tasks whose latest status is `completed`.
- Tasks with latest status `failed`, `claimed` (stale), or no status (`new`) are eligible.
- With `--skip-failed`, also skips tasks with `failed` or `claimed` status.
- Verifies all `requires` dependencies are marked `completed` in the ledger.
- Returns the first valid ID and its status.
