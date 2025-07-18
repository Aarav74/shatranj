from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, Text, ForeignKey, Index, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from datetime import datetime, timedelta
import json
import chess
import chess.pgn
from typing import Dict, List, Optional, Union
import uuid
from pydantic import BaseModel, Field, validator
import asyncio
import logging
import os
from sqlalchemy.exc import IntegrityError

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database Models
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    # Use UUID column type that matches your database
    id = Column(UUID(as_uuid=False), primary_key=True, server_default=text("uuid_generate_v4()"))
    username = Column(String(255), unique=True, nullable=False, index=True)
    email = Column(String(255), nullable=False, unique=True)
    rating = Column(Integer, default=1200)
    games_played = Column(Integer, default=0)
    games_won = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    is_online = Column(Boolean, default=False)
    last_seen = Column(DateTime(timezone=True), server_default=text("NOW()"))
    created_at = Column(DateTime(timezone=True), server_default=text("NOW()"))

class Game(Base):
    __tablename__ = "games"
    
    # Use UUID column type that matches your database
    id = Column(UUID(as_uuid=False), primary_key=True, server_default=text("uuid_generate_v4()"))
    white_player_id = Column(UUID(as_uuid=False), ForeignKey("users.id"), nullable=False)
    black_player_id = Column(UUID(as_uuid=False), ForeignKey("users.id"), nullable=True)
    status = Column(String(50), default="waiting", index=True)
    current_turn = Column(String(10), default="white")
    fen = Column(String(100), default="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    pgn = Column(Text, default="")
    result = Column(String(50), nullable=True)
    termination = Column(String(50), nullable=True)
    time_control = Column(Integer, default=600)
    increment = Column(Integer, default=0)
    white_time_left = Column(Integer, default=600)
    black_time_left = Column(Integer, default=600)
    last_move_time = Column(DateTime(timezone=True), server_default=text("NOW()"))
    created_at = Column(DateTime(timezone=True), server_default=text("NOW()"))
    updated_at = Column(DateTime(timezone=True), server_default=text("NOW()"))
    
    white_player = relationship("User", foreign_keys=[white_player_id])
    black_player = relationship("User", foreign_keys=[black_player_id])
    moves = relationship("Move", back_populates="game", cascade="all, delete-orphan")

class Move(Base):
    __tablename__ = "moves"
    
    id = Column(Integer, primary_key=True, index=True)
    game_id = Column(UUID(as_uuid=False), ForeignKey("games.id", ondelete="CASCADE"), nullable=False)
    player_id = Column(UUID(as_uuid=False), ForeignKey("users.id"), nullable=False)
    move_notation = Column(String(10), nullable=False)
    san_notation = Column(String(10), nullable=False)
    fen_before = Column(String(100), nullable=False)
    fen_after = Column(String(100), nullable=False)
    move_number = Column(Integer, nullable=False)
    white_time_left = Column(Integer, nullable=False)
    black_time_left = Column(Integer, nullable=False)
    timestamp = Column(DateTime(timezone=True), server_default=text("NOW()"))
    
    game = relationship("Game", back_populates="moves")
    player = relationship("User")

# Add indexes for better performance
Index('idx_games_status', Game.status)
Index('idx_games_players', Game.white_player_id, Game.black_player_id)
Index('idx_moves_game', Move.game_id)

# Pydantic Models
class UserResponse(BaseModel):
    id: str
    username: str
    rating: int
    games_played: int
    games_won: int
    is_online: bool
    last_seen: datetime
    created_at: datetime

    class Config:
        from_attributes = True

    @validator('id', pre=True)
    def convert_uuid_to_string(cls, v):
        return str(v) if v is not None else None

class GameCreate(BaseModel):
    time_control: int = Field(default=600, ge=30, le=3600)
    increment: int = Field(default=0, ge=0, le=30)
    player_name: str = Field(..., min_length=1, max_length=50)

class GameResponse(BaseModel):
    id: str
    white_player_id: str
    black_player_id: Optional[str] = None
    status: str
    current_turn: str
    fen: str
    result: Optional[str] = None
    termination: Optional[str] = None
    time_control: int
    increment: int
    white_time_left: int
    black_time_left: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

    @validator('id', 'white_player_id', 'black_player_id', pre=True)
    def convert_uuid_to_string(cls, v):
        return str(v) if v is not None else None

class MoveRequest(BaseModel):
    move: str = Field(..., pattern=r'^[a-h][1-8][a-h][1-8][qrbn]?$')
    player_id: str

class MoveResponse(BaseModel):
    id: int
    game_id: str
    player_id: str
    move_notation: str
    san_notation: str
    fen_after: str
    move_number: int
    white_time_left: int
    black_time_left: int
    timestamp: datetime

    class Config:
        from_attributes = True

    @validator('game_id', 'player_id', pre=True)
    def convert_uuid_to_string(cls, v):
        return str(v) if v is not None else None

class JoinGameRequest(BaseModel):
    player_name: str = Field(..., min_length=1, max_length=50)

# Configuration
class Settings:
    def __init__(self):
        # Database configuration
        self.database_url = os.getenv(
            "DATABASE_URL", 
            "postgresql://postgres.pqadpbxjnlxytomzmnwa:070804@aws-0-ap-south-1.pooler.supabase.com:5432/postgres"
        )
        
        # Connection pool settings
        self.db_pool_size = 5
        self.db_max_overflow = 10
        self.db_pool_recycle = 3600
        
        # CORS settings
        self.cors_origins = [
            "http://localhost:3000",
            "http://localhost:8000", 
            "http://127.0.0.1:8000",
            "http://192.168.1.8:8000",
            "*"
        ]

# Create an instance of Settings
settings = Settings()

# Database Configuration
try:
    engine = create_engine(
        settings.database_url,
        pool_pre_ping=True,
        pool_size=settings.db_pool_size,
        max_overflow=settings.db_max_overflow,
        pool_recycle=settings.db_pool_recycle,
        connect_args={
            "keepalives": 1,
            "keepalives_idle": 30,
            "keepalives_interval": 10,
            "keepalives_count": 5
        }
    )
    # Test the connection
    with engine.connect() as conn:
        logger.info("✅ Successfully connected to the database")
except Exception as e:
    logger.error(f"❌ Failed to connect to database: {e}")
    logger.info("⚠️ Falling back to SQLite for local development")
    # Fallback to SQLite - but note: this won't work well with UUID types
    settings.database_url = "sqlite:///./local.db"
    engine = create_engine(
        settings.database_url,
        connect_args={"check_same_thread": False}
    )

# Always rebind SessionLocal after engine is set
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# DON'T create tables here - they already exist in your database
# Base.metadata.create_all(bind=engine)

# FastAPI App
app = FastAPI(
    title="Chess Game API",
    version="2.0.0",
    description="A comprehensive chess game backend with real-time multiplayer support"
)

# CORS Middleware
allow_credentials = True
if '*' in settings.cors_origins:
    allow_credentials = False

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Fixed helper function - don't manually set UUIDs, let database handle it
def get_or_create_user(db: Session, username: str, email: str) -> User:
    user = db.query(User).filter(User.username == username).first()
    if not user:
        user = User(username=username, email=email)  # Let database generate UUID
        db.add(user)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            user = db.query(User).filter(User.username == username).first()
            if user:
                return user
            else:
                raise
        db.refresh(user)
    return user

# WebSocket Connection Manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}  # game_id -> {user_id: websocket}
        self.user_games: Dict[str, str] = {}  # user_id -> game_id

    async def connect(self, websocket: WebSocket, game_id: str, user_id: str):
        await websocket.accept()
        if game_id not in self.active_connections:
            self.active_connections[game_id] = {}
        
        self.active_connections[game_id][user_id] = websocket
        self.user_games[user_id] = game_id

    def disconnect(self, websocket: WebSocket, game_id: str, user_id: str):
        if game_id in self.active_connections:
            if user_id in self.active_connections[game_id]:
                del self.active_connections[game_id][user_id]
            if not self.active_connections[game_id]:
                del self.active_connections[game_id]
        
        if user_id in self.user_games:
            del self.user_games[user_id]

    async def broadcast_to_game(self, message: dict, game_id: str):
        if game_id in self.active_connections:
            for user_id, connection in self.active_connections[game_id].items():
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Error sending message to user {user_id}: {e}")

    async def send_to_user(self, message: dict, game_id: str, user_id: str):
        if game_id in self.active_connections and user_id in self.active_connections[game_id]:
            try:
                await self.active_connections[game_id][user_id].send_json(message)
            except Exception as e:
                logger.error(f"Error sending message to user {user_id}: {e}")

manager = ConnectionManager()

# Chess Game Logic
class ChessGameLogic:
    @staticmethod
    def validate_move(fen: str, move: str) -> tuple[bool, str, str]:
        """Validate a chess move and return new FEN if valid"""
        try:
            board = chess.Board(fen)
            chess_move = chess.Move.from_uci(move)
            
            if chess_move in board.legal_moves:
                san_notation = board.san(chess_move)
                board.push(chess_move)
                return True, board.fen(), san_notation
            else:
                return False, "", ""
        except Exception as e:
            logger.error(f"Error validating move: {e}")
            return False, "", ""
    
    @staticmethod
    def check_game_end(fen: str) -> Optional[str]:
        """Check if game has ended and return result"""
        try:
            board = chess.Board(fen)
            if board.is_checkmate():
                return "black_wins" if board.turn else "white_wins"
            elif board.is_stalemate() or board.is_insufficient_material() or board.is_seventyfive_moves() or board.is_fivefold_repetition():
                return "draw"
            return None
        except Exception as e:
            logger.error(f"Error checking game end: {e}")
            return None

# API Routes

# User Management
@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.get("/users/", response_model=List[UserResponse])
async def get_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    users = db.query(User).offset(skip).limit(limit).all()
    return users

# Game Management
@app.post("/games/", response_model=GameResponse)
async def create_game(game_data: GameCreate, db: Session = Depends(get_db)):
    try:
        # Get or create user
        user = get_or_create_user(db, game_data.player_name, f"{game_data.player_name}@example.com")
        
        # Create game with proper datetime objects
        current_time = datetime.utcnow()
        db_game = Game(
            white_player_id=user.id,
            time_control=game_data.time_control,
            increment=game_data.increment,
            white_time_left=game_data.time_control,
            black_time_left=game_data.time_control,
            last_move_time=current_time,
            created_at=current_time,
            updated_at=current_time
        )
        
        db.add(db_game)
        db.commit()
        db.refresh(db_game)
        
        # Create proper response object
        game_response = GameResponse(
            id=str(db_game.id),
            white_player_id=str(db_game.white_player_id),
            black_player_id=str(db_game.black_player_id) if db_game.black_player_id else None,
            status=db_game.status,
            current_turn=db_game.current_turn,
            fen=db_game.fen,
            result=db_game.result,
            termination=db_game.termination,
            time_control=db_game.time_control,
            increment=db_game.increment,
            white_time_left=db_game.white_time_left,
            black_time_left=db_game.black_time_left,
            created_at=db_game.created_at,
            updated_at=db_game.updated_at
        )
        
        return game_response
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating game: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create game: {str(e)}")

@app.get("/games/{game_id}", response_model=GameResponse)
async def get_game(game_id: str, db: Session = Depends(get_db)):
    game = db.query(Game).filter(Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")
    return game

@app.get("/")
async def root():
    return {
        "message": "Chess Game API",
        "version": "2.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "redoc": "/redoc",
            "games": "/games/",
            "websocket": "/ws/{game_id}?player_name={player_name}"
        },
        "timestamp": datetime.utcnow().isoformat()
    }

# Enhanced health check with more details
@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        # Test database connection
        db.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"
    
    return {
        "status": "healthy",
        "database": db_status,
        "timestamp": datetime.utcnow().isoformat(),
        "active_games": len(manager.active_connections),
        "version": "2.0.0"
    }

# Debug endpoint to check current configuration
@app.get("/debug/config")
async def debug_config():
    return {
        "database_url": settings.database_url.replace(
            settings.database_url.split('@')[0].split('://')[1], 
            "***:***"
        ) if '@' in settings.database_url else settings.database_url,
        "cors_origins": settings.cors_origins,
        "active_connections": {
            game_id: list(connections.keys()) 
            for game_id, connections in manager.active_connections.items()
        }
    }

# Test endpoint to create a sample game
@app.post("/debug/create-test-game")
async def create_test_game(db: Session = Depends(get_db)):
    try:
        # Create a test game
        game_data = GameCreate(
            player_name="TestPlayer",
            time_control=600,
            increment=0
        )
        
        user = get_or_create_user(db, game_data.player_name, f"{game_data.player_name}@example.com")
        
        current_time = datetime.utcnow()
        db_game = Game(
            white_player_id=user.id,
            time_control=game_data.time_control,
            increment=game_data.increment,
            white_time_left=game_data.time_control,
            black_time_left=game_data.time_control,
            last_move_time=current_time,
            created_at=current_time,
            updated_at=current_time
        )
        db.add(db_game)
        db.commit()
        db.refresh(db_game)
        
        return {
            "message": "Test game created successfully",
            "game_id": str(db_game.id),
            "player_id": str(user.id),
            "websocket_url": f"ws://localhost:8000/ws/{db_game.id}?player_name=TestPlayer"
        }
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating test game: {e}")
        return {
            "error": str(e),
            "message": "Failed to create test game"
        }

@app.post("/games/{game_id}/join")
async def join_game(game_id: str, join_data: JoinGameRequest, db: Session = Depends(get_db)):
    try:
        game = db.query(Game).filter(Game.id == game_id).first()
        if not game:
            raise HTTPException(status_code=404, detail="Game not found")
        
        if game.status != "waiting":
            raise HTTPException(status_code=400, detail="Game is not waiting for players")
        
        # Get or create user
        user = get_or_create_user(db, join_data.player_name, f"{join_data.player_name}@example.com")
        
        if str(game.white_player_id) == str(user.id):
            raise HTTPException(status_code=400, detail="You are already in this game")
        
        if game.black_player_id is None:
            game.black_player_id = user.id
            game.status = "active"
            game.updated_at = datetime.utcnow()
            db.commit()
            db.refresh(game)
            
            # Create proper response
            game_response = GameResponse(
                id=str(game.id),
                white_player_id=str(game.white_player_id),
                black_player_id=str(game.black_player_id) if game.black_player_id else None,
                status=game.status,
                current_turn=game.current_turn,
                fen=game.fen,
                result=game.result,
                termination=game.termination,
                time_control=game.time_control,
                increment=game.increment,
                white_time_left=game.white_time_left,
                black_time_left=game.black_time_left,
                created_at=game.created_at,
                updated_at=game.updated_at
            )
            
            # Broadcast game start to all connections
            await manager.broadcast_to_game({
                "type": "game_started",
                "game": jsonable_encoder(game_response)
            }, game_id)
            
            return {"message": "Joined game successfully", "player_id": str(user.id)}
        else:
            raise HTTPException(status_code=400, detail="Game is full")
            
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error joining game: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to join game: {str(e)}")

@app.get("/games/{game_id}/moves")
async def get_game_moves(game_id: str, db: Session = Depends(get_db)):
    moves = db.query(Move).filter(Move.game_id == game_id).order_by(Move.move_number).all()
    return moves

@app.get("/games/", response_model=List[GameResponse])
async def get_games(skip: int = 0, limit: int = 10, status: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Game)
    if status:
        query = query.filter(Game.status == status)
    games = query.offset(skip).limit(limit).all()
    return games

# Move Validation and Processing
@app.post("/games/{game_id}/moves", response_model=MoveResponse)
async def make_move(game_id: str, move_request: MoveRequest, db: Session = Depends(get_db)):
    try:
        game = db.query(Game).filter(Game.id == game_id).first()
        if not game:
            raise HTTPException(status_code=404, detail="Game not found")
        
        if game.status != "active":
            raise HTTPException(status_code=400, detail="Game is not active")
        
        # Check if it's the player's turn
        if (game.current_turn == "white" and str(game.white_player_id) != move_request.player_id) or \
           (game.current_turn == "black" and str(game.black_player_id) != move_request.player_id):
            raise HTTPException(status_code=400, detail="It's not your turn")
        
        # Calculate time remaining
        current_time = datetime.utcnow()
        time_elapsed = (current_time - game.last_move_time).total_seconds()
        
        if game.current_turn == "white":
            game.white_time_left = max(0, game.white_time_left - time_elapsed) + game.increment
        else:
            game.black_time_left = max(0, game.black_time_left - time_elapsed) + game.increment
        
        # Check for timeout
        if (game.current_turn == "white" and game.white_time_left <= 0) or \
           (game.current_turn == "black" and game.black_time_left <= 0):
            game.status = "finished"
            game.result = "black_wins" if game.current_turn == "white" else "white_wins"
            game.termination = "timeout"
            db.commit()
            
            await manager.broadcast_to_game({
                "type": "game_ended",
                "game": {
                    "id": str(game.id),
                    "result": game.result,
                    "termination": game.termination,
                    "white_time_left": game.white_time_left,
                    "black_time_left": game.black_time_left
                }
            }, game_id)
            
            raise HTTPException(status_code=400, detail="Time expired")
        
        # Validate the move
        is_valid, new_fen, san_notation = ChessGameLogic.validate_move(game.fen, move_request.move)
        if not is_valid:
            raise HTTPException(status_code=400, detail="Invalid move")
        
        # Get move number
        move_count = db.query(Move).filter(Move.game_id == game_id).count()
        move_number = move_count + 1
        
        # Create move record
        db_move = Move(
            game_id=game_id,
            player_id=move_request.player_id,
            move_notation=move_request.move,
            san_notation=san_notation,
            fen_before=game.fen,
            fen_after=new_fen,
            move_number=move_number,
            white_time_left=int(game.white_time_left),
            black_time_left=int(game.black_time_left),
            timestamp=current_time
        )
        db.add(db_move)
        
        # Update game state
        game.fen = new_fen
        game.current_turn = "black" if game.current_turn == "white" else "white"
        game.last_move_time = current_time
        game.updated_at = current_time
        
        # Check for game end
        game_result = ChessGameLogic.check_game_end(new_fen)
        if game_result:
            game.result = game_result
            game.status = "finished"
            game.termination = "checkmate" if "wins" in game_result else "stalemate"
            
            # Update player statistics
            white_player = db.query(User).filter(User.id == game.white_player_id).first()
            black_player = db.query(User).filter(User.id == game.black_player_id).first()
            
            if white_player:
                white_player.games_played += 1
                if game_result == "white_wins":
                    white_player.games_won += 1
            
            if black_player:
                black_player.games_played += 1
                if game_result == "black_wins":
                    black_player.games_won += 1
        
        db.commit()
        db.refresh(db_move)
        
        # Create proper move response
        move_response = MoveResponse(
            id=db_move.id,
            game_id=str(db_move.game_id),
            player_id=str(db_move.player_id),
            move_notation=db_move.move_notation,
            san_notation=db_move.san_notation,
            fen_after=db_move.fen_after,
            move_number=db_move.move_number,
            white_time_left=db_move.white_time_left,
            black_time_left=db_move.black_time_left,
            timestamp=db_move.timestamp
        )
        
        # Broadcast move to all players in the game
        await manager.broadcast_to_game({
            "type": "move_made",
            "move": jsonable_encoder(move_response),
            "game_state": {
                "current_turn": game.current_turn,
                "status": game.status,
                "result": game.result,
                "termination": game.termination
            }
        }, game_id)
        
        return move_response
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error making move: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to make move: {str(e)}")

# Game Actions
@app.post("/games/{game_id}/resign")
async def resign_game(game_id: str, player_id: str, db: Session = Depends(get_db)):
    try:
        game = db.query(Game).filter(Game.id == game_id).first()
        if not game:
            raise HTTPException(status_code=404, detail="Game not found")
        if game.status != "active":
            raise HTTPException(status_code=400, detail="Game is not active")
        if player_id not in [str(game.white_player_id), str(game.black_player_id)]:
            raise HTTPException(status_code=403, detail="You are not a player in this game")
        # Set game result
        game.status = "finished"
        game.termination = "resignation"
        game.result = "black_wins" if player_id == str(game.white_player_id) else "white_wins"
        game.updated_at = datetime.utcnow()
        # Update player statistics
        white_player = db.query(User).filter(User.id == game.white_player_id).first()
        black_player = db.query(User).filter(User.id == game.black_player_id).first()
        if white_player:
            white_player.games_played += 1
            if game.result == "white_wins":
                white_player.games_won += 1
        if black_player:
            black_player.games_played += 1
            if game.result == "black_wins":
                black_player.games_won += 1
        db.commit()
        # Broadcast resignation
        await manager.broadcast_to_game({
            "type": "game_ended",
            "game": jsonable_encoder(GameResponse.from_orm(game)),
            "resigned_by": str(player_id)
        }, game_id)
        return {"message": "Game resigned successfully"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error resigning game: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to resign game: {str(e)}")

# WebSocket Endpoint
@app.websocket("/ws/{game_id}")
async def websocket_endpoint(websocket: WebSocket, game_id: str, player_name: str):
    db = None
    try:
        db = SessionLocal()
        # Get or create user
        user = get_or_create_user(db, player_name, f"{player_name}@example.com")
        # Check if game exists
        game = db.query(Game).filter(Game.id == game_id).first()
        if not game:
            await websocket.close(code=4004, reason="Game not found")
            return
        await manager.connect(websocket, game_id, user.id)
        # Send initial game state
        await websocket.send_json({
            "type": "game_state",
            "game": jsonable_encoder(GameResponse.from_orm(game)),
            "player_id": str(user.id)
        })
        try:
            while True:
                data = await websocket.receive_json()
                if data["type"] == "ping":
                    await websocket.send_json({"type": "pong"})
                elif data["type"] == "request_game_state":
                    db.refresh(game)
                    await websocket.send_json({
                        "type": "game_state",
                        "game": jsonable_encoder(GameResponse.from_orm(game)),
                        "player_id": str(user.id)
                    })
        except WebSocketDisconnect:
            manager.disconnect(websocket, game_id, user.id)
        finally:
            if db:
                db.close()
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        if db:
            db.close()
        await websocket.close(code=4000, reason="Internal server error")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)