---
name: pocketbase
description: PocketBase development skill — project setup, schema iteration, JS migrations, and dev server operations.
---

# Skill: PocketBase

Complete reference for PocketBase development. Covers initial project setup, dev server operations, schema iteration workflow, and JS migration API.

**Invocation**: The directive-task-planner runs the Setup Steps during bootstrap. Task workers reference the Iteration Workflow and JS Migration Reference during schema and feature work.

## Prerequisites

- Go 1.23+ installed and on PATH
- **Working directory**: Always run go commands from the workspace root using `go -C pb`. Never `cd` into `pb/` directly.

## Setup Steps

Follow these steps in order when setting up a new PocketBase project.

### Step 1: Prompt for Configuration

Ask the user for the following values:

| Variable           | Description                  | Default            |
|--------------------|------------------------------|--------------------|
| `PB_PORT`          | Port for PocketBase server   | `8090`             |
| `PB_ADMIN_EMAIL`   | Superuser email              | *(required)*       |
| `PB_ADMIN_PASSWORD` | Superuser password          | *(required)*       |
| `PB_MODULE_NAME`   | Go module name               | Infer from project |

### Step 2: Create Directory Structure

```
pb/
├── main.go
├── go.mod          (generated)
├── go.sum          (generated)
├── pb_migrations/
│   └── .gitkeep
└── pb_hooks/
    └── .gitkeep
scripts/
├── pb-dev.sh
└── pb-reset.sh
```

### Step 3: Create `pb/main.go`

```go
package main

import (
	"log"
	"os"
	"strings"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/plugins/jsvm"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

func main() {
	app := pocketbase.New()

	// Enable automigrate only during development (go run)
	isGoRun := strings.HasPrefix(os.Args[0], os.TempDir())

	jsvm.MustRegister(app, jsvm.Config{
		MigrationsDir: "pb_migrations",
	})

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		TemplateLang: migratecmd.TemplateLangJS,
		Automigrate:  isGoRun,
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
```

### Step 4: Initialize Go Module

```bash
go -C pb mod init <PB_MODULE_NAME>
go -C pb mod tidy
```

### Step 5: Create `pb/.env`

```bash
PB_PORT=<prompted value>
PB_ADMIN_EMAIL=<prompted value>
PB_ADMIN_PASSWORD=<prompted value>
```

### Step 6: Create `scripts/pb-dev.sh`

```bash
#!/bin/bash
# pb-dev.sh: Start PocketBase dev server (kills existing instance first)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PB_DIR="$SCRIPT_DIR/../pb"
ENV_FILE="$PB_DIR/.env"

# Source config
if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE"; set +a
fi
PORT="${PB_PORT:-8090}"

# Kill existing instance
PID=$(lsof -ti :"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then
  echo "Stopping PocketBase on port $PORT (PID: $PID)"
  kill "$PID" 2>/dev/null || true
  sleep 1
fi

# Start server
echo "Starting PocketBase on port $PORT..."
cd "$PB_DIR"
exec go run . serve --http="127.0.0.1:$PORT"
```

### Step 7: Create `scripts/pb-reset.sh`

```bash
#!/bin/bash
# pb-reset.sh: Wipe PocketBase data, create superuser, and start fresh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PB_DIR="$SCRIPT_DIR/../pb"
ENV_FILE="$PB_DIR/.env"

# Source config
if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE"; set +a
fi
PORT="${PB_PORT:-8090}"

# Kill existing instance
PID=$(lsof -ti :"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then
  echo "Stopping PocketBase on port $PORT (PID: $PID)"
  kill "$PID" 2>/dev/null || true
  sleep 1
fi

# Wipe data
if [ -d "$PB_DIR/pb_data" ]; then
  echo "Removing pb_data..."
  rm -rf "$PB_DIR/pb_data"
fi

# Create superuser (initializes fresh DB)
if [ -n "$PB_ADMIN_EMAIL" ] && [ -n "$PB_ADMIN_PASSWORD" ]; then
  echo "Creating superuser..."
  cd "$PB_DIR"
  go run . superuser upsert "$PB_ADMIN_EMAIL" "$PB_ADMIN_PASSWORD"
else
  echo "Warning: PB_ADMIN_EMAIL or PB_ADMIN_PASSWORD not set. Skipping superuser creation."
fi

# Start server
echo "Starting PocketBase on port $PORT..."
cd "$PB_DIR"
exec go run . serve --http="127.0.0.1:$PORT"
```

### Step 8: Make Scripts Executable

```bash
chmod +x scripts/pb-dev.sh scripts/pb-reset.sh
```

### Step 9: Update `.gitignore`

Add these entries:

```
# PocketBase
pb/pb_data/
pb/pocketbase
pb/.env
```

### Step 10: Verify Setup

Run the reset script to confirm everything works:

```bash
bash scripts/pb-reset.sh
```

Expected outcome:
- PocketBase compiles and starts
- Superuser is created
- Server is accessible at `http://127.0.0.1:<PB_PORT>`
- Admin dashboard at `http://127.0.0.1:<PB_PORT>/_/`

## Iteration Workflow

| Action | Command |
|--------|---------|
| Start server | `bash scripts/pb-dev.sh` |
| Wipe DB and restart | `bash scripts/pb-reset.sh` |
| Stop server | `Ctrl+C` (runs in foreground) |

### Schema Change Loop

The recommended workflow for iterating on schema:

1. **Write or edit migration files** in `pb/pb_migrations/`
2. **Run `bash scripts/pb-reset.sh`** — wipes DB, re-runs all migrations from scratch, creates superuser
3. **Verify** — check the admin dashboard at `/_/` or hit the API

Migrations run automatically on server start. The reset script gives a clean slate every time, so you can freely edit migration files and re-test.

### Automigrate (Dashboard Mode)

When running via `go run` (which `pb-dev.sh` uses), `Automigrate` is enabled. This means changes made in the admin dashboard (`/_/`) automatically generate JS migration files in `pb_migrations/`. These files should be committed to version control.

### Hooks

Add JS hooks in `pb/pb_hooks/` using the `*.pb.js` naming pattern. They hot-reload automatically during development.

---

## JS Migration Reference

Migration files live in `pb/pb_migrations/` and run in filename order on server start.

### File Naming

```
pb_migrations/{unix_timestamp}_{description}.js
```

Example: `pb_migrations/1687801097_create_posts.js`

To generate a new migration file via CLI:

```bash
go -C pb run . migrate create "description_here"
```

### Migration Structure

```javascript
migrate((app) => {
  // UP — apply changes
}, (app) => {
  // DOWN — revert changes (optional but recommended)
})
```

Both callbacks receive a transactional `app` instance.

### Create a Collection

```javascript
migrate((app) => {
  const collection = new Collection({
    type: "base",          // "base", "auth", or "view"
    name: "posts",
    listRule: "@request.auth.id != ''",
    viewRule: "@request.auth.id != ''",
    createRule: "@request.auth.id != ''",
    updateRule: "author = @request.auth.id",
    deleteRule: "author = @request.auth.id",
    fields: [
      new TextField({ name: "title", required: true, max: 200 }),
      new EditorField({ name: "body" }),
      new SelectField({ name: "status", values: ["draft", "published"], maxSelect: 1 }),
      new RelationField({
        name: "author",
        collectionId: "COLLECTION_ID_HERE",
        maxSelect: 1,
        cascadeDelete: false
      }),
      new AutodateField({ name: "created", onCreate: true, onUpdate: false }),
      new AutodateField({ name: "updated", onCreate: true, onUpdate: true }),
    ],
    indexes: [
      "CREATE INDEX idx_posts_status ON posts (status)",
    ],
  })
  app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("posts")
  app.delete(collection)
})
```

### Create an Auth Collection

```javascript
migrate((app) => {
  const collection = new Collection({
    type: "auth",
    name: "users",
    listRule: "id = @request.auth.id",
    viewRule: "id = @request.auth.id",
    createRule: "",
    updateRule: "id = @request.auth.id",
    deleteRule: null,
    fields: [
      new TextField({ name: "displayName", max: 100 }),
    ],
    passwordAuth: { enabled: true },
  })
  app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("users")
  app.delete(collection)
})
```

### Modify an Existing Collection

```javascript
migrate((app) => {
  const collection = app.findCollectionByNameOrId("posts")

  // Add a field
  collection.fields.add(new BoolField({ name: "featured" }))

  // Remove a field
  collection.fields.removeByName("old_field")

  // Modify a field
  const titleField = collection.fields.getByName("title")
  titleField.max = 500

  // Update API rules
  collection.listRule = ""

  app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("posts")
  collection.fields.removeByName("featured")
  collection.listRule = "@request.auth.id != ''"
  app.save(collection)
})
```

### Relation Lookup by Name

When creating relations, you need the target collection's ID. Look it up by name:

```javascript
migrate((app) => {
  const users = app.findCollectionByNameOrId("users")

  const collection = new Collection({
    type: "base",
    name: "posts",
    fields: [
      new TextField({ name: "title", required: true }),
      new RelationField({
        name: "author",
        collectionId: users.id,     // resolved at migration time
        maxSelect: 1,
        cascadeDelete: false,
      }),
    ],
  })
  app.save(collection)
})
```

### Seed Data in Migrations

```javascript
migrate((app) => {
  const collection = app.findCollectionByNameOrId("categories")
  for (const name of ["Work", "Personal", "Shopping"]) {
    const record = new Record(collection)
    record.set("name", name)
    app.save(record)
  }
})
```

### Raw SQL

```javascript
migrate((app) => {
  app.db().newQuery("UPDATE posts SET status = 'draft' WHERE status = ''").execute()
})
```

### Field Types Quick Reference

| Constructor | Key Options |
|-------------|-------------|
| `TextField` | `required`, `min`, `max`, `pattern` |
| `NumberField` | `required`, `min`, `max`, `onlyInt` |
| `BoolField` | `required` |
| `EmailField` | `required`, `onlyDomains`, `exceptDomains` |
| `URLField` | `required`, `onlyDomains`, `exceptDomains` |
| `DateField` | `required` |
| `AutodateField` | `onCreate`, `onUpdate` |
| `SelectField` | `values` (required), `maxSelect` |
| `FileField` | `maxSelect`, `maxSize`, `mimeTypes`, `thumbs`, `protected` |
| `RelationField` | `collectionId` (required), `maxSelect`, `cascadeDelete` |
| `JSONField` | `required` (nullable unlike other fields) |
| `EditorField` | `required`, `maxSize`, `convertURLs` |
| `PasswordField` | `required`, `min`, `max`, `cost` |
| `GeoPointField` | `required` |

### API Rules Quick Reference

| Value | Meaning |
|-------|---------|
| `null` | Superuser only (locked) |
| `""` | Public access (no auth required) |
| `"@request.auth.id != ''"` | Any authenticated user |
| `"author = @request.auth.id"` | Owner only (field `author` matches current user) |
| `"@request.auth.verified = true"` | Verified users only |

Rules support: `=`, `!=`, `>`, `>=`, `<`, `<=`, `~` (contains), `!~`, `&&`, `||`

For multi-value relation checks use `?=`: `"members ?= @request.auth.id"`
