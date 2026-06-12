# Detailed Plan for Godot‑Based Markdown Note App

## 1️⃣ Directory layout (under `/mnt/h/GodotProjects/Obsessed`)
```
/mnt/c/Godot\ Projects/Obsessed/
├── vault/          # plain .md files, sub‑folders only – the user’s notebook 
├── backend/        # FastAPI Python service
│   ├── app.py
│   └── requirements.txt
├── godot/          # Godot 4 project for UI
│   ├── main.tscn   # root scene
│   ├── scripts/
│   │   └── Main.gd
│   └── ui/
└── docker/         # Docker / compose configs for CI and dev
    ├── Dockerfile.backend
    ├── docker-compose.yml
```

## 2️⃣ FastAPI backend (Python)
- **Purpose**: CRUD on markdown files in `vault/`, simple API, optional preview rendering.
- **Endpoints**
  - `GET /api/fs?path=` → list folders/files.
  - `GET /api/file?path=` → raw content.
  - `POST /api/file` (JSON: `{"path":str,"content":str}`) → create/edit.
  - `DELETE /api/file?path=` → delete file/folder.
  - `GET /api/preview?path=` → return previewed HTML via markdown library.
- **Code** in `backend/app.py` (see implementation plan).
- **Requirements** in `backend/requirements.txt`. 

## 3️⃣ Godot frontend
- Root scene: split view – left `Tree` for browsing, right editor‑preview panel.
- Scripts:
  - `Main.gd`: on startup launch backend via `OS.execute("python", ["-m","uvicorn","backend.app:app","--port","8008"], true)` or rely on external Docker service.
  - Use Godot’s `HTTPRequest`/`HTTPClient` to call FastAPI.
  - When a file node is selected, fetch its content and load into a `TextEdit`; preview rendered HTML in a sibling `RichTextLabel`.
- Animations: folder expand/collapse via Tween, fade transitions for preview panel.

## 4️⃣ Packaging & Deployment
- **Docker Compose** (`docker-compose.yml`) builds two services:
  - `obsessed-backend`: uses `backend/requirements.txt`, exposes port 8008.
  - `obsessed-godot` (optional) or simply export Godot exe locally.
- **Runtime script** – `launch.bat` on Windows: start python server, wait a bit, then launch exported `.exe`.

## 5️⃣ Development Workflow
1. Initialise repo and pull dependencies (`pip install -r backend/requirements.txt`).
2. Run backend manually (`uvicorn backend.app:app --reload`).
3. In Godot editor press `Play`, confirm UI loads via localhost.
4. Export to Windows – generate `Obsessed.exe`.
5. Distribute the exe together with a folder containing the python runtime and `backend/` code, or use the batch script.

## 6️⃣ Future Enhancements (optional)
- WebSocket for real‑time collaborative editing.
- Dark mode toggle in Godot UI.
- File tag support via front‑matter parsing.
- Simple authentication token added to FastAPI.

---
**Next steps:** Create the skeleton files (`backend/app.py`, `docker-compose.yml`, etc.) following this plan. Let me know when you’d like me to start building them. (End of Plan)