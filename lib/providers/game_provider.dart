// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../models/game_models.dart';
import '../services/api_service.dart';

class GameProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Game? _currentGame;
  final List<Move> _moves = [];
  String? _playerId;
  String? _playerName;
  WebSocketChannel? _channel;
  GameStatus _status = GameStatus.disconnected;
  String? _error;
  int _whiteTimeLeft = 600;
  int _blackTimeLeft = 600;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  
  // Network configuration - choose the right one for your setup
  // Your physical device IP
  static const String computerIp = '192.168.1.8:8000'; // UPDATE THIS if your IP changes

  // Helper method to get the correct base URL for different platforms
  String get baseUrl {
    if (kIsWeb) {
      // For web, always use localhost since the browser runs on the same machine
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // For Android emulator use: 'http://10.0.2.2:8000'
      // For physical Android device use your computer's IP
      return 'http://192.168.1.8:8000';
    } else if (Platform.isIOS) {
      // For iOS simulator use: 'http://localhost:8000'
      // For physical iOS device use your computer's IP  
      return 'http://192.168.1.8:8000';
    } else {
      return 'http://localhost:8000'; // Default to localhost
    }
  }

  // Helper method to get base URL (keeping both methods for compatibility)
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // return 'http://10.0.2.2:8000'; // Uncomment if using emulator
      return 'http://$computerIp';      // Physical device
    } else if (Platform.isIOS) {
      // return 'http://localhost:8000'; // Uncomment if using simulator
      return 'http://$computerIp';      // Physical device
    } else {
      return 'http://localhost:8000';
    }
  }

  String getWebSocketUrl(String gameId, String playerName) {
    // Use the same host as your base URL, but ws:// instead of http://
    final wsHost = getBaseUrl().replaceFirst('http', 'ws');
    return '$wsHost/ws/$gameId?player_name=${Uri.encodeComponent(playerName)}';
  }

  // Helper method to convert string status to GameStatus enum
  GameStatus _stringToGameStatus(String status) {
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
      case 'disconnected':
        return GameStatus.disconnected;
      default:
        return GameStatus.disconnected;
    }
  }
  
  // Getters
  Game? get currentGame => _currentGame;
  List<Move> get moves => _moves;
  String? get playerId => _playerId;
  String? get playerName => _playerName;
  GameStatus get status => _status;
  String? get error => _error;
  int get whiteTimeLeft => _whiteTimeLeft;
  int get blackTimeLeft => _blackTimeLeft;
  bool get isMyTurn => _currentGame != null && 
    ((_currentGame!.currentTurn == 'white' && _currentGame!.whitePlayerId == _playerId) ||
     (_currentGame!.currentTurn == 'black' && _currentGame!.blackPlayerId == _playerId));
  
  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }
  
  // Test network connectivity
  Future<bool> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      
      return false;
    } catch (e) {
      if (e is SocketException) {
        // Network error
      } else if (e is TimeoutException) {
        // Timeout error
      } else {
        // Other error
      }
      
      return false;
    }
  }
  
  Future<void> createGame({
    required String playerName,
    int timeControl = 600,
    int increment = 0,
  }) async {
    try {
      _status = GameStatus.loading;
      _error = null;
      notifyListeners();
      
      // Test connection first
      final isConnected = await _testConnection();
      if (!isConnected) {
        String troubleshooting = '''
Cannot connect to server at $baseUrl.

Troubleshooting steps:
1. Make sure the server is running:
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload

2. Check your network configuration:
   - Current configuration: $baseUrl
   
3. Platform-specific settings:
   - Android Emulator: use 10.0.2.2:8000
   - iOS Simulator: use localhost:8000
   - Physical Device: use your computer's IP address

4. Find your computer's IP address:
   - Windows: ipconfig
   - Mac/Linux: ifconfig or ip addr

5. Make sure your device and computer are on the same WiFi network

6. Check if firewall is blocking port 8000
''';
        throw Exception(troubleshooting);
      }
      
      final game = await _apiService.createGame(
        playerName: playerName,
        timeControl: timeControl,
        increment: increment,
      );
      
      _currentGame = game;
      _playerId = game.whitePlayerId;
      _playerName = playerName;
      _whiteTimeLeft = timeControl;
      _blackTimeLeft = timeControl;
      _status = GameStatus.waiting;
      
      await _connectWebSocket(game.id, playerName);
      
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      _status = GameStatus.error;
      notifyListeners();
    }
  }
  
  Future<void> joinGame(String gameId, String playerName) async {
    try {
      _status = GameStatus.loading;
      _error = null;
      notifyListeners();
      
      // Test connection first
      final isConnected = await _testConnection();
      if (!isConnected) {
        String troubleshooting = '''
Cannot connect to server at $baseUrl.

Troubleshooting steps:
1. Make sure the server is running:
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload

2. Check your network configuration:
   - Current configuration: $baseUrl
   
3. Platform-specific settings:
   - Android Emulator: use 10.0.2.2:8000
   - iOS Simulator: use localhost:8000
   - Physical Device: use your computer's IP address

4. Find your computer's IP address:
   - Windows: ipconfig
   - Mac/Linux: ifconfig or ip addr

5. Make sure your device and computer are on the same WiFi network

6. Check if firewall is blocking port 8000
''';
        throw Exception(troubleshooting);
      }
      
      final result = await _apiService.joinGame(gameId, playerName);
      _playerId = result['player_id'];
      _playerName = playerName;
      
      final game = await _apiService.getGame(gameId);
      _currentGame = game;
      _whiteTimeLeft = game.whiteTimeLeft;
      _blackTimeLeft = game.blackTimeLeft;
      
      await _connectWebSocket(gameId, playerName);
      
      _status = GameStatus.active;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      _status = GameStatus.error;
      notifyListeners();
    }
  }
  
  Future<void> makeMove(String move) async {
    if (_currentGame == null || _playerId == null) return;
    
    try {
      await _apiService.makeMove(
        gameId: _currentGame!.id,
        move: move,
        playerId: _playerId!,
      );
      
      // Clear any previous errors on successful move
      _error = null;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> resignGame() async {
    if (_currentGame == null || _playerId == null) return;
    
    try {
      await _apiService.resignGame(_currentGame!.id, _playerId!);
      _error = null;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> _connectWebSocket(String gameId, String playerName) async {
    try {
      _channel?.sink.close();
      _reconnectAttempts = 0;
      
      final wsUrl = getWebSocketUrl(gameId, playerName);
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _handleWebSocketMessage(message);
            _reconnectAttempts = 0; // Reset on successful message
          } catch (e) {
            _error = 'Error parsing server message';
            notifyListeners();
          }
        },
        onError: (error) {
          _error = 'Connection error: $error';
          _status = GameStatus.error;
          notifyListeners();
          _attemptReconnect(gameId, playerName);
        },
        onDone: () {
          if (_status != GameStatus.finished) {
            _status = GameStatus.disconnected;
            notifyListeners();
            _attemptReconnect(gameId, playerName);
          }
        },
      );
      
      // Send a ping to test the connection
      await Future.delayed(const Duration(seconds: 1));
      _sendPing();
      
    } catch (e) {
      _error = 'Failed to connect: $e';
      _status = GameStatus.error;
      notifyListeners();
    }
  }
  
  void _attemptReconnect(String gameId, String playerName) {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _error = 'Failed to reconnect after $maxReconnectAttempts attempts';
      _status = GameStatus.error;
      notifyListeners();
      return;
    }
    
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    
    _reconnectTimer = Timer(Duration(seconds: 2 * _reconnectAttempts), () {
      _connectWebSocket(gameId, playerName);
    });
  }
  
  void _sendPing() {
    try {
      _channel?.sink.add(jsonEncode({
        'type': 'ping',
      }));
    } catch (e) {
      // Ignore ping errors
    }
  }
  
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'pong':
        // Ping response received
        break;
        
      case 'game_state':
        final gameData = message['game'];
        _currentGame = Game.fromJson(gameData);
        _playerId = message['player_id'];
        _whiteTimeLeft = gameData['white_time_left'] ?? 600;
        _blackTimeLeft = gameData['black_time_left'] ?? 600;
        
        // Use the helper method to convert string to GameStatus
        _status = _stringToGameStatus(gameData['status'] ?? 'disconnected');
        break;
        
      case 'game_started':
        final gameData = message['game'];
        _currentGame = Game.fromJson(gameData);
        _status = GameStatus.active;
        break;
        
      case 'move_made':
        final moveData = message['move'];
        final gameStateData = message['game_state'];
        
        _moves.add(Move.fromJson(moveData));
        
        if (_currentGame != null) {
          // Create a new Game object with updated values, ensuring all fields are properly converted
          _currentGame = Game(
            id: _currentGame!.id,
            whitePlayerId: _currentGame!.whitePlayerId,
            blackPlayerId: _currentGame!.blackPlayerId,
            status: gameStateData['status'] ?? _currentGame!.status,  // Keep as string
            currentTurn: gameStateData['current_turn'] ?? _currentGame!.currentTurn,
            fen: moveData['fen_after'] ?? _currentGame!.fen,
            result: gameStateData['result'],
            termination: gameStateData['termination'],
            timeControl: _currentGame!.timeControl,
            increment: _currentGame!.increment,
            whiteTimeLeft: moveData['white_time_left'] ?? _currentGame!.whiteTimeLeft,
            blackTimeLeft: moveData['black_time_left'] ?? _currentGame!.blackTimeLeft,
            createdAt: _currentGame!.createdAt,
            updatedAt: _currentGame!.updatedAt,
          );
          
          _whiteTimeLeft = moveData['white_time_left'];
          _blackTimeLeft = moveData['black_time_left'];
          
          // Use the helper method to convert string to GameStatus
          _status = _stringToGameStatus(gameStateData['status'] ?? 'active');
        }
        break;
        
      case 'game_ended':
        final gameData = message['game'];
        if (_currentGame != null) {
          // Create a new Game object with updated values
          _currentGame = Game(
            id: _currentGame!.id,
            whitePlayerId: _currentGame!.whitePlayerId,
            blackPlayerId: _currentGame!.blackPlayerId,
            status: 'finished',  // Keep as string
            currentTurn: _currentGame!.currentTurn,
            fen: _currentGame!.fen,
            result: gameData['result'],
            termination: gameData['termination'],
            timeControl: _currentGame!.timeControl,
            increment: _currentGame!.increment,
            whiteTimeLeft: _currentGame!.whiteTimeLeft,
            blackTimeLeft: _currentGame!.blackTimeLeft,
            createdAt: _currentGame!.createdAt,
            updatedAt: _currentGame!.updatedAt,
          );
        }
        _status = GameStatus.finished;
        break;
        
      default:
        // Unknown message type
        break;
    }
    
    notifyListeners();
  }
  
  void requestGameState() {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'request_game_state',
        }));
      } catch (e) {
        // Ignore request errors
      }
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _currentGame = null;
    _moves.clear();
    _playerId = null;
    _playerName = null;
    _status = GameStatus.disconnected;
    _error = null;
    _reconnectAttempts = 0;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    disconnect();
    super.dispose();
  }
}