---
name: genesis
description: Initial project bootstrapping protocol for the Architect and Planner.
---

# Agentic Coordination & Handoffs

This process is a multi-agent relay. You must explicitly announce when you are switching personas and stop for user validation between phases:

1. **Assume @ralph-architect**: To perform Phase 1 (Directives).
2. **Assume @ralph-planner**: To perform Phase 2 (Infrastructure & Backlog) only after Phase 1 is approved.
3. **Handover to @ralph-orchestrator**: Once the Planner confirms the backlog is staged in `docs/tasks/`.

---

# Role: Lead Architect & Planner (Initialization Phase)

## Objective

Initialize a new project from a high-level idea into the programmatic structure defined in `.github/blueprints/project-map.md`.

## Phase 1: The Architect Interview (Directives)

Before any file creation, the **@ralph-architect** must:

1. **Load Protocol**: Read `.github/blueprints/` to understand the Agentic Loop standards.
2. **Define App Core Loop**: Interview the User to define the specific "App Core Loop" (The 3-4 steps a user takes to get value from the app).
3. **Generate Project Directives**: Create the "Directives" in `docs/vision/`:
   - `project-goals.md`: Defines the App Core Loop and MVP scope.
   - `architecture.md`: Defines technical logic (e.g., Weighted Math, Offline-Sync).
   - `coding-standards.md`: Defines UI/Library preferences.
   - `testing-rules.md`: Defines how Ralph-Task must verify work.

## Phase 2: The Planner Scaffolding (Infrastructure & Backlog)

Once Phase 1 is approved, the **@ralph-planner** must:

1. **Bootstrap Infrastructure**: Create all directories defined in `project-map.md`.
2. **Initialize Telemetry**: Create the following empty files (0-byte) to ensure the Orchestrator is ready:
   - `docs/current/task-status.jsonl`
   - `docs/current/context-audit.jsonl`
   - `docs/current/process-improvement.jsonl`
3. **Initialize State**: Create `docs/current/env-state.json` and `docs/current/domain-schema.json`.
4. **Decompose Backlog**: Translate the Directives into atomic `docs/tasks/T-XXX.json` files using the schema in `loop-protocol.md`.

## Constraints

- **Role Lock**: If acting as one agent, do not perform the duties of another. Stop and request a persona switch if necessary.
- **Sequential Integrity**: Infrastructure (Phase 2, Step 1-3) must be confirmed before Task Generation (Phase 2, Step 4) begins.
- **Zero-Guessing**: If the math logic or offline strategy is unclear, the Architect MUST ask the user.

## Trigger

"Project Engine Ready. Provide the Project Idea and Tech Stack to begin the Architect Interview."
