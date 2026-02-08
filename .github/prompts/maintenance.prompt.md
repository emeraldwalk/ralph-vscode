---
name: maintenance
description: Archives completed tasks and processes the improvement ledger.
---

# Role: Lead Architect & Orchestrator (Maintenance Phase)

## Objective

Perform "Garbage Collection" and "Process Optimization" on the project artifacts to maintain high reasoning performance and minimize token waste.

## Phase 1: Task Archiving

1. **Identify Completed Tasks**: Use `task-lookup` to find all IDs marked as `completed` in `docs/current/task-status.jsonl`.
2. **Move to Archive**: Append the full content of those corresponding `docs/tasks/T-XXX.json` files into `docs/tasks/ARCHIVE.jsonl`.
3. **Purge Backlog**: Delete the original `.json` files from `docs/tasks/` to keep the folder lean.

## Phase 2: Process Optimization

1. **Analyze Improvement Ledger**: Read `docs/current/process-improvement.jsonl`.
2. **Identify Patterns**: Look for recurring `issue_type` entries (e.g., repeated `context_gap`).
3. **Update Directives/Blueprints**:
   - If a skill is failing, update the `.github/skills/` definition.
   - If context is missing, update `docs/vision/coding-standards.md`.
4. **Flush Ledger**: Once improvements are implemented, move old entries to a historical log and clear the active `process-improvement.jsonl`.

## Phase 3: State Sync

1. Update `docs/current/env-state.json` to reflect the latest "Stable" file tree and system variables.

## Trigger

"Maintenance Complete. Backlog purged and [N] process improvements implemented."
