# Project Directory Map

## 1. Directory Tree

```text
.
├── .github/
│   ├── agents/             <-- PERSONAS (Who am I?)
│   │   ├── ralph-architect.agent.md
│   │   ├── ralph-directive-task-planner.agent.md
│   │   ├── ralph-orchestrator.agent.md
│   │   ├── ralph-task-planner.agent.md
│   │   └── ralph-task.agent.md
│   ├── blueprints/         <-- PROTOCOLS (How do we work?)
│   │   ├── project-map.md
│   │   └── loop-protocol.md
│   ├── prompts/            <-- OPERATIONS
│   │   └── task-package.prompt.md
│   └── skills/             <-- SKILLS (Agent Tools)
│       ├── find-task/
│       │   └── SKILL.md
│       ├── next-task/
│       │   └── SKILL.md
│       └── pocketbase/
│           └── SKILL.md
├── app/                    <-- PRODUCT (Code Target)
│   ├── src/
│   └── tests/
├── docs/                   <-- ARTIFACTS (Paper Trail)
│   ├── current/            <-- STATE (Mutable)
│   │   ├── task-status.jsonl
│   │   ├── domain-schema.json
│   │   └── env-state.json
│   ├── tasks/              <-- BACKLOG (Individual Tasks)
│   │   ├── T-001.json
│   │   ├── T-002.json
│   │   └── ARCHIVE.jsonl
│   └── vision/             <-- DIRECTIVES (Fixed Truths)
│       ├── project-goals.md
│       ├── architecture.md
│       ├── coding-standards.md
│       └── testing-rules.md
└── process.log/            <-- LOGS (Ignore)
    └── execution.log
```
