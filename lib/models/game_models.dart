enum GameStatus {
  disconnected,
  loading,
  waiting,
  active,
  finished,
  error,
}

class Game {
  final String id;
  final String whitePlayerId;
  final String? blackPlayerId;
  final String status; // Stored as string from backend
  final String currentTurn;
  final String fen;
  final String? result;
  final String? termination;
  final int timeControl;
  final int increment;
  final int whiteTimeLeft;
  final int blackTimeLeft;
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    required this.id,
    required this.whitePlayerId,
    this.blackPlayerId,
    required this.status,
    required this.currentTurn,
    required this.fen,
    this.result,
    this.termination,
    required this.timeControl,
    required this.increment,
    required this.whiteTimeLeft,
    required this.blackTimeLeft,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts the status string to enum
  GameStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'waiting':
        return GameStatus.waiting;
      case 'active':
        return GameStatus.active;
      case 'finished':
        return GameStatus.finished;
      case 'loading':
        return GameStatus.loading;
      case 'error':
        return GameStatus.error;
      default:
        return GameStatus.disconnected;
    }
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'].toString(),
      whitePlayerId: json['white_player_id'].toString(),
      blackPlayerId: json['black_player_id']?.toString(),
      status: json['status'].toString(), // Ensure it's a string
      currentTurn: json['current_turn'].toString(),
      fen: json['fen'].toString(),
      result: json['result']?.toString(),
      termination: json['termination']?.toString(),
      timeControl: json['time_control'] is int ? json['time_control'] : int.parse(json['time_control'].toString()),
      increment: json['increment'] is int ? json['increment'] : int.parse(json['increment'].toString()),
      whiteTimeLeft: json['white_time_left'] is int ? json['white_time_left'] : int.parse(json['white_time_left'].toString()),
      blackTimeLeft: json['black_time_left'] is int ? json['black_time_left'] : int.parse(json['black_time_left'].toString()),
      createdAt: json['created_at'] is DateTime ? json['created_at'] : DateTime.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] is DateTime ? json['updated_at'] : DateTime.parse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'white_player_id': whitePlayerId,
      'black_player_id': blackPlayerId,
      'status': status,
      'current_turn': currentTurn,
      'fen': fen,
      'result': result,
      'termination': termination,
      'time_control': timeControl,
      'increment': increment,
      'white_time_left': whiteTimeLeft,
      'black_time_left': blackTimeLeft,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Game copyWith({
    String? status,
    String? currentTurn,
    String? fen,
    String? result,
    String? termination,
    int? whiteTimeLeft,
    int? blackTimeLeft,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id,
      whitePlayerId: whitePlayerId,
      blackPlayerId: blackPlayerId,
      status: status ?? this.status,
      currentTurn: currentTurn ?? this.currentTurn,
      fen: fen ?? this.fen,
      result: result ?? this.result,
      termination: termination ?? this.termination,
      timeControl: timeControl,
      increment: increment,
      whiteTimeLeft: whiteTimeLeft ?? this.whiteTimeLeft,
      blackTimeLeft: blackTimeLeft ?? this.blackTimeLeft,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Move {
  final int id;
  final String gameId;
  final String playerId;
  final String moveNotation;
  final String sanNotation;
  final String fenAfter;
  final int moveNumber;
  final int whiteTimeLeft;
  final int blackTimeLeft;
  final DateTime timestamp;

  Move({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.moveNotation,
    required this.sanNotation,
    required this.fenAfter,
    required this.moveNumber,
    required this.whiteTimeLeft,
    required this.blackTimeLeft,
    required this.timestamp,
  });

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      gameId: json['game_id'].toString(),
      playerId: json['player_id'].toString(),
      moveNotation: json['move_notation'].toString(),
      sanNotation: json['san_notation'].toString(),
      fenAfter: json['fen_after'].toString(),
      moveNumber: json['move_number'] is int ? json['move_number'] : int.parse(json['move_number'].toString()),
      whiteTimeLeft: json['white_time_left'] is int ? json['white_time_left'] : int.parse(json['white_time_left'].toString()),
      blackTimeLeft: json['black_time_left'] is int ? json['black_time_left'] : int.parse(json['black_time_left'].toString()),
      timestamp: json['timestamp'] is DateTime ? json['timestamp'] : DateTime.parse(json['timestamp'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'player_id': playerId,
      'move_notation': moveNotation,
      'san_notation': sanNotation,
      'fen_after': fenAfter,
      'move_number': moveNumber,
      'white_time_left': whiteTimeLeft,
      'black_time_left': blackTimeLeft,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}