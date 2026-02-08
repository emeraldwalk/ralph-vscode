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
"skills": ["task-lookup"]
},
"acceptance_criteria": [
"Criterion 1 (e.g. Component renders without errors)",
"Criterion 2 (e.g. Data persists to PocketBase)"
],
"verification_command": "npm test or custom shell command"
}

## 2. Status Ledger Schema (`docs/current/task-status.jsonl`)

The **Orchestrator** is the SOLE authority permitted to append to this file.
Format: JSON Lines (one JSON object per line).

{"id": "T-001", "status": "claimed", "updated_at": "ISO-8601", "summary": "Task claimed by Ralph-Task"}
{"id": "T-001", "status": "completed", "updated_at": "ISO-8601", "summary": "Successfully initialized PB client", "delta": "Created src/lib/pb.js"}

## 3. Improvement Ledger Schema (`docs/current/process-improvement.jsonl`)

Any agent encountering friction MUST append a line to this ledger.
Format: JSON Lines (one JSON object per line).

{
"task_id": "T-XXX",
"issue_type": "tool_failure | context_gap | logic_bottleneck | redundant_step",
"observation": "Short description of the friction point.",
"suggestion": "How to fix the blueprint or agent prompt to prevent this.",
"timestamp": "ISO-8601"
}

## 4. Context Audit Ledger (`docs/current/context-audit.jsonl`)

The Orchestrator must log the "Intentional Context" before every Ralph-Task briefing.

{
"task_id": "T-XXX",
"file_count": 3,
"line_count": 450,
"files": ["app/src/lib/pb.js", "docs/vision/architecture.md"],
"timestamp": "ISO-8601"
}

## 5. Operational Rules

### A. The "Atomic" Constraint

- If a task requires modifying more than 3 existing files, the **Planner** must refactor it into smaller sub-tasks.

### B. The "Surgical" Read Rule

- Agents must NOT read entire `.jsonl` files into context.
- Use the **`task-lookup`** skill to extract ONLY the most recent relevant lines.

### C. The "Bootstrap" Requirement

- The **Planner** must initialize `task-status.jsonl` and `process-improvement.jsonl` as empty files.
- The **Orchestrator** must fail-fast if these files are missing.
