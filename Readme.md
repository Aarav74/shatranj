# ♟️ Real-Time Chess Game Platform

This project is a full-stack real-time multiplayer chess game built using:

- **Backend**: FastAPI + PostgreSQL + WebSocket  
- **Frontend**: Flutter (WebSocket-enabled client)

---

## 📦 Features

- Create or join live chess games  
- Real-time synchronization using WebSockets  
- Automatic game state management (checkmate, timeout, resignation)  
- PGN and FEN tracking  
- Time control with increment support  
- Player statistics (games played, won, etc.)  
- Reconnection handling and game recovery  
- API documented via FastAPI's Swagger `/docs`

---

## 🧠 Tech Stack

### Backend
- [FastAPI](https://fastapi.tiangolo.com/)
- PostgreSQL (via SQLAlchemy ORM)
- `python-chess` for game logic
- WebSocket real-time updates
- UUID support and health checks

### Frontend
- [Flutter](https://flutter.dev/)
- WebSocket channel
- Provider state management
- Reconnect logic and error handling

---

## 🚀 Getting Started

### Backend (Python + FastAPI)

#### Prerequisites
- Python 3.10+
- PostgreSQL
- `uuid-ossp` extension enabled in PostgreSQL

#### Install Dependencies
```bash
pip install -r requirements.txt
```

#### Run the API
```bash
uvicorn bea6ca14-21af-4667-b3c7-c66d3fc7015e:app --reload
```

> Replace `bea6ca14...py` with your backend Python file name if renamed.

#### Environment Variables
Set `DATABASE_URL` in `.env` or environment:
```env
DATABASE_URL=postgresql://username:password@host:port/dbname
```

---

### Frontend (Flutter)

#### Prerequisites
- Flutter SDK
- Android Studio / VS Code

#### Install Dependencies
```bash
flutter pub get
```

#### Run App
```bash
flutter run
```

Make sure the `computerIp` in the Dart file is updated to match your local backend IP:
```dart
static const String computerIp = '192.168.1.X:8000';
```

---

## 🧪 API Highlights

- `POST /games/` - Create game  
- `POST /games/{id}/join` - Join existing game  
- `POST /games/{id}/moves` - Make a move  
- `POST /games/{id}/resign` - Resign a game  
- `GET /games/{id}` - Fetch game state  
- `GET /health` - Health check  
- `WebSocket /ws/{game_id}?player_name=...` - Real-time updates

---

## 🧰 Useful Dev Endpoints

- `GET /debug/config` - Show current server config  
- `POST /debug/create-test-game` - Creates a quick test game

---

## 📸 Screenshots (Optional)

> You can add screenshots of the mobile interface or game board here.

---

## 📄 License

MIT License. Feel free to fork, improve, or contribute!

---

## 👥 Credits

- Backend: FastAPI, SQLAlchemy, `python-chess`  
- Frontend: Flutter, WebSocket, Provider
