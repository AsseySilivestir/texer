# texer

A web app built with **Bantu** + **Sua** + **SQLite**. Scaffolded by `bantu init --web`.

## Run locally

### Option A — Linux / macOS

```bash
./start.sh
```

Open http://localhost:8080.

### Option B — Windows

Double-click `start.bat`. (Requires `bantu.exe` + its DLLs in this folder — grab them from the [bantusua-local release](https://github.com/AsseySilivestir/bantusua-local/releases).)

### Option C — Anywhere with `bantu` on PATH

```bash
bantu run main.b
```

## API

| Method | Path              | Purpose              |
|--------|-------------------|----------------------|
| GET    | `/api/health`     | Health check (JSON)  |
| GET    | `/api/items`      | List items           |
| POST   | `/api/items`      | Create item `{name}` |
| DELETE | `/api/items/:id`  | Delete item          |
| GET    | `/`               | Static frontend      |

## Database

SQLite file at `./app.db` locally, or `/data/app.db` on Render (persistent volume).

## Deploy to Render

1. Push this repo to GitHub.
2. Render → New → Blueprint → connect the repo.
3. Render detects `render.yaml` and creates the service.
4. The Dockerfile builds `bantu` from source inside Ubuntu 22.04 (ABI-safe), then runs `bantu run main.b`.

## Edit & iterate

- Edit `main.b` → restart the server (`Ctrl-C` then re-run).
- Edit `public/*` → just refresh the browser (no build step).
- Add new routes: copy the pattern of `handleList` / `handleCreate`.

## Project structure

```
texer/
├── main.b              ← backend (single Bantu file)
├── public/             ← frontend (vanilla HTML/CSS/JS)
│   ├── index.html
│   ├── css/style.css
│   └── js/app.js
├── start.sh            ← Linux/Mac launcher
├── start.bat           ← Windows launcher
├── Dockerfile          ← Render-ready multi-stage build
├── render.yaml         ← Render blueprint
├── bantu.json          ← project config
├── .gitignore
└── README.md
```

## Learn more

- Bantu language: https://github.com/AsseySilivestir/bantu-lang
- Example app: https://github.com/AsseySilivestir/bantusua-local (ChatBantu — full social network)
