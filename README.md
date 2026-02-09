# Ralph VS Code

A multi-agent orchestration framework for VS Code that coordinates specialized AI agents to plan, decompose, and execute software development tasks.

## What It Does

Ralph implements an "agentic loop" where five AI agent personas collaborate through a formal protocol:

1. **Architect** — Interviews the user to define project goals, architecture, coding standards, and testing rules. Outputs directive documents to `docs/vision/`.
2. **Bootstrapper** — Reads the architect's directives, initializes project infrastructure (directories, ledgers, runs setup skills), and decomposes the vision into an actionable task backlog.
3. **Task Planner** — Creates atomic task files (`docs/tasks/T-XXX.json`) from ad-hoc prompts, using the same format as the bootstrapper. Use this to add tasks to the backlog after the initial setup.
4. **Orchestrator** — The loop coordinator. Picks the next ready task, claims it, audits context, briefs the worker agent, and logs the outcome to append-only ledgers.
5. **Task Worker** — Receives a briefing, modifies application code, runs verification, and reports a context delta back to the orchestrator.

## How It Works

```
User prompt
  → Architect (defines vision & directives)
    → Bootstrapper (sets up infra, creates task backlog)
      → Orchestrator loop:
          1. Find next unclaimed task (respects dependencies)
          2. Claim it, audit context
          3. Brief the Task Worker
          4. Worker implements, verifies, reports back
          5. Log completion → repeat
```

All state is tracked in append-only JSONL ledgers (`docs/current/`), giving a full audit trail of claims, completions, failures, and process improvements.

## Repository Layout

```
.github/
  agents/          # Agent persona definitions (who does what)
  blueprints/      # Protocol docs — task schema, ledger formats, constraints
  prompts/         # Briefing templates populated at runtime
  skills/          # Reusable bash tools (extensible per project):
    next-task/        Find the next ready task from the backlog
    find-task/        Look up a task's latest status
    pocketbase/       Example skill: PocketBase server lifecycle
    pocketbase-schema/ Example skill: PocketBase schema migrations
docs/
  vision/          # Architect directives (project-goals, architecture, etc.)
  tasks/           # Task backlog (T-001.json, T-002.json, …)
  current/         # Runtime ledgers (task-status, process-improvement, context-audit)
```

## Tech Stack

- **LLMs** — agent reasoning (supports any model provider)
- **Bash** — all skills are shell scripts
- **VS Code** — IDE integration via custom agents and settings

Skills are the extension point for project-specific tooling. The repo ships with PocketBase skills as a working example, but you can add skills for any stack (Docker, database migrations, deploy scripts, etc.).
