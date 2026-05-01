---
name: segmentcli
description: >-
  Use the `segmentcli` CLI to drive a Segment workspace — list sources, manage
  Analytics Live Plugins, send test analytics events, import CSV data, and
  scaffold plugin/edge-function/importer code. Use whenever the user mentions
  "segmentcli", asks to upload/disable a Live Plugin, list Segment sources,
  send a track/identify/etc. event from the terminal, import a CSV into
  Segment, or scaffold a Segment plugin or edge function.
---

# segmentcli

CLI for working with Segment workspaces. Sources upstream:
[`segment-integrations/segmentcli`](https://github.com/segment-integrations/segmentcli).
Installs as `/usr/local/bin/segmentcli` via `sudo make install` from a checkout.

## Look things up before answering

Always prefer `--help` over guessing — the CLI is small and self-documenting:

- `segmentcli --help` — top-level groups and commands
- `segmentcli <group> --help` — subcommands of a group
- `segmentcli <group> <subcommand> --help` — exact arguments
- `segmentcli version` — version string (currently `1.0.0`)

## Authentication & profiles

State lives in `~/.segmentcli` (JSON). Profiles are workspace tokens with a
local nickname.

- **Auth** (one-time per workspace): `segmentcli auth <ProfileName> <AuthToken>`
- **List**: `segmentcli profile list`
- **Set default**: `segmentcli profile set <ProfileName>`
- **Delete**: `segmentcli profile delete <ProfileName>`
- Most commands accept `-p, --profile <name>` to override the default profile
  for that single call.
- `--staging` global flag routes to `api.segmentapis.build` (Segment internal staging).

### Getting a token

1. https://app.segment.com → Settings → Workspace Settings → Access Management → Tokens
2. *Create token* with the **Workspace Owner** role (required for full CLI access).
3. Token format starts with `sgp_…`.

### EU workspaces

The Public API is single-host (`https://api.segmentapis.com`); for EU
workspaces it 30x's to `https://eu1.api.segmentapis.com`. The CLI's auth
session preserves the `Authorization` header across the redirect, so EU
auth works transparently — but only on builds that include the
"re-attach Authorization on redirect" fix. If an EU workspace returns
"Supplied token is not authorized" or "Authorization header is required",
the binary is too old; rebuild from `master`.

> Note: `eu1.api.segmentapis.com` is the EU Public API host (Public API only).
> `events.eu1.segmentapis.com` is the EU **event ingestion** host (TAPI) — used
> by analytics SDKs at runtime, NOT by `segmentcli`.

## Read-only commands (safe to run anytime)

- `segmentcli version`
- `segmentcli profile list`
- `segmentcli sources list` — lists all sources in the workspace (name, id, type, write keys)
- `segmentcli liveplugins latest <sourceId>` — info on the live plugin currently bound to a source
- `segmentcli analytics list` — show locally-pending event batches (does not contact Segment)

## Write / side-effecting commands (confirm before running)

These either mutate workspace state, send live event traffic, write to disk,
or modify local profile state. **Always echo the intended command back to the
user and confirm before running.** Don't auto-fire them.

- `segmentcli auth <Profile> <Token>` — writes a profile to `~/.segmentcli`
- `segmentcli profile set/delete` — mutates local profile state
- `segmentcli liveplugins upload <sourceId> <filePath>` — deploys a Live Plugin to a source
- `segmentcli liveplugins disable <sourceId>` — disables Live Plugins for a source
- `segmentcli analytics {track,identify,screen,group,alias} <writeKey> …` — sends real events
- `segmentcli analytics flush` — flushes locally-queued events to Segment
- `segmentcli analytics reset` — clears local anonId/userId
- `segmentcli import <writeKey> <csvFile>` — bulk-ingests CSV rows as events
- `segmentcli scaffold {-p|-e|-i} [--swift|--kotlin|--java|--objc|--js|--ts] [-n NAME]` — generates code files in CWD
- `segmentcli repl` — interactive Substrata JS REPL

## Common workflows

### Find a source's ID
1. `segmentcli sources list`
2. Match by name; record `id` field. (Or grab from app.segment.com → Connections → Sources → API Keys.)

### Ship a Live Plugin
1. Scaffold: `segmentcli scaffold --plugin --swift -n MyPlugin` (or `--kotlin`/`--java`/`--objc`/`--ts`)
2. Edit the generated file.
3. `segmentcli liveplugins upload <sourceId> <path/to/plugin.js>` (the deployed file is the JS bundle, not the platform source).
4. Verify: `segmentcli liveplugins latest <sourceId>`. Settings propagation can take a few minutes.

### Test events from the terminal
1. Find the source's write key: `segmentcli sources list`.
2. `segmentcli analytics track <writeKey> "Event Name" key=value other=val --flush`
3. `--flush` ensures the batch is sent before the process exits; without it, events sit locally until `analytics flush` is run.

### Import a CSV
1. `segmentcli analytics list` to confirm queue state.
2. `segmentcli import <writeKey> data.csv`
3. The CLI batches rows as track events (one per row). Large files take a while.

### Scaffold an edge function
- `segmentcli scaffold --edgefn --js -n MyEdgeFn` → drops a JS template in CWD.

## Guardrails

- **Confirm before any write.** Especially `liveplugins upload`, `liveplugins disable`, `analytics track/identify/...`, and `import` — they all hit production by default. Use `--staging` if available and intended.
- **Never paste a token into chat or commit it.** Tokens are workspace-scoped and grant full Workspace Owner access. The token lives in `~/.segmentcli` (mode 644 — flag if storing on a shared host).
- **Don't run `repl` non-interactively** — it expects a TTY.
- **Source IDs vs write keys** are different. Live plugin / sources commands take **source IDs** (a short opaque ID per source). Analytics and import commands take **write keys** (a separate opaque ID, also per source). Both are in `sources list` output.
- **Settings file at `~/.segmentcli`** is plain JSON; safe to inspect/back up but treat as a secret.

## When the CLI is not the right tool

- **Bulk Public API operations** (filtering, pagination, fields the CLI doesn't surface): hit `https://api.segmentapis.com` directly with `curl`. The official SDKs are at https://github.com/segmentio (Go, Python, Java, C#, TypeScript, Swift).
- **Event ingestion at scale**: use a real Segment SDK in your app, not `analytics track`.
- **Tracking Plans / Destinations / Warehouses CRUD**: not exposed by `segmentcli`; use the Public API or app.segment.com.

## References

- Repo: https://github.com/segment-integrations/segmentcli
- Public API docs: https://docs.segmentapis.com
- Regional Segment (EU): https://segment.com/docs/guides/regional-segment/
- Analytics Live Plugins SDKs: [Swift](https://github.com/segment-integrations/analytics-swift-live), [Kotlin](https://github.com/segment-integrations/analytics-kotlin-live)
