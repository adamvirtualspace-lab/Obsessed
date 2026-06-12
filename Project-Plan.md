# Project Plan – Obsessed

## Overview

This repository contains a minimal, self‑hostable note application that mimics Obsidian’s **plain‑markdown** workflow. The front‑end is a Godot web export while a small FastAPI backend serves both the static files and provides CRUD endpoints for `.md` notes.

### Folder Structure
```
/Obsessed/
├─ vault/            # plain markdown files – your "Obsidian" vault
├─ backend/          # FastAPI code (Python)
│  ├─ main.py        # API routes + static file serving
│  └─ requirements.txt
└─ web/
   └─ godot_export/  # Godot HTML5 build (index.html, *.wasm/.pck, etc.)
```

## Development Flow (in brief)
1. **Create /update the FastAPI server** – see `backend/main.py`.
2. **Export Godot UI as a web build** → put output into `web/godot_export/`.
3. **Run dev server**:
```bash
uvicorn backend.main:app --reload --port 8008
```
4. **Test in the browser or via Godot’s HTTPRequest node**.
5. **Publish** – keep both `vault/`, `backend/` and `web/godot_export/` bundled together for deployment.

## API Endpoints (FastAPI)
| Method | Path                | Purpose                         |
|--------|---------------------|----------------------------------|
| GET    | `/api/files?path=`   | List files/folders relative to vault |
| POST   | `/api/file/{path}`  | Write / create a markdown file     |
| GET    | `/api/file/{path}`  | Read a markdown file              |
| DELETE | `/api/file`         | Delete a file or folder           |

Static files (`index.html`, etc.) are served automatically from `web/godot_export/` via the default FastAPI static‑files mount.

## Local Server & LAN Access
Run:
```bash
uvicorn backend.main:app --host 0.0.0.0 --port 8008
```
Any device on the same network can visit `http://<PC-ip>:8008` to see the note viewer.

> **Tip** – For mobile or TV access, just load the same URL in a web browser; all UI logic is delivered through Godot’s web export.

## Next Steps
- [ ] Create/confirm `backend/main.py` with CRUD and static mount.
- [ ] Build Godot web export into `web/godot_export/`.
- [ ] Verify API routes work locally.
- [ ] Package everything for distribution (Python + Godot build).
