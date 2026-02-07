# Loop Protocol: Operational Standards

This document defines the strict programmatic interface for the Agentic Loop. All agents must adhere to these schemas to ensure compatibility with `jq` and cross-agent handovers.

## 1. Task Definition Schema (`docs/tasks/T-XXX.json`)

The Planner must generate individual JSON files for every atomic unit of work.

{
"id": "T-XXX",
"title": "Short descriptive title",
"description": "Detailed explanation of the goal",
"requires": ["T-001", "T-002"],
"context": {
"files": ["app/src/path/to/file.js"],
"docs": ["docs/vision/project-goals.md"],
"skills": ["task-indexer"]
},
"acceptance_criteria": [
"Criterion 1 (e.g. Component renders without errors)",
"Criterion 2 (e.g. Data persists to PocketBase)"
],
"verification_command": "npm test or custom shell command"
}

## 2. Status Ledger Schema (`docs/current/task-status.jsonl`)

The **Orchestrator** is the SOLE authority permitted to append to this file.
Format: JSON Lines (one JSON object per line, no trailing commas).

{"id": "T-001", "status": "pending", "updated_at": "2026-02-07T15:00:00Z", "summary": "Task initialized by Orchestrator"}
{"id": "T-001", "status": "in-progress", "updated_at": "2026-02-07T15:10:00Z", "summary": "Assigned to Ralph-Task"}
{"id": "T-001", "status": "completed", "updated_at": "2026-02-07T15:30:00Z", "summary": "Successfully initialized PB client", "delta": {"files_added": ["app/src/lib/pb.js"]}}

## 3. Operational Rules

### A. The "Atomic" Constraint

- A task is valid ONLY if it focuses on a single logical change.
- If a task requires modifying more than 3 existing files, the **Planner** must refactor it into smaller sub-tasks.

### B. The "Surgical" Read Rule

- Agents must NOT read the entire `task-status.jsonl` into context.
- Use the **`task-indexer`** skill (via `tail` or `grep`) to extract only the most recent line for a specific ID.

### C. The "Bootstrap" Requirement

- The **Planner** must initialize `docs/current/task-status.jsonl` as an empty file before the loop begins.
- The **Orchestrator** must fail-fast if this file is missing.

### D. Task Transitions

1. **Pending**: Task exists in `docs/tasks/` and has been added to the ledger.
2. **In-Progress**: Sub-agent has been briefed and is actively editing code.
3. **Completed**: Verification command passed and "Context Delta" received.
4. **Failed/Blocked**: Issue identified. Orchestrator must decide to retry or create a new "Fix" task.

## 4. Maintenance & Archiving

When `docs/tasks/` contains more than 10 `completed` tasks, the **Maintenance Prompt** should be triggered to move those JSON files into `docs/tasks/ARCHIVE.jsonl` to keep the workspace clean.
