import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_models.dart';
import 'package:shatranj/utils/network_utils.dart';

class ApiService {
  String get baseUrl => getBaseUrl();
  
  Future<Game> createGame({
    required String playerName,
    int timeControl = 600,
    int increment = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'player_name': playerName,
          'time_control': timeControl,
          'increment': increment,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Game.fromJson(data);
      } else {
        throw Exception('Failed to create game: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Game> getGame(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Game.fromJson(data);
      } else {
        throw Exception('Failed to get game: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> joinGame(String gameId, String playerName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'player_name': playerName,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to join game: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Move> makeMove({
    required String gameId,
    required String move,
    required String playerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/moves'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'move': move,
          'player_id': playerId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Move.fromJson(data);
      } else {
        throw Exception('Failed to make move: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<void> resignGame(String gameId, String playerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/resign?player_id=$playerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to resign: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<List<Game>> getGames({int skip = 0, int limit = 10, String? status}) async {
    try {
      String url = '$baseUrl/games/?skip=$skip&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> gamesList = jsonDecode(response.body);
        return gamesList.map((json) => Game.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get games: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<List<Move>> getGameMoves(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/moves'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> movesList = jsonDecode(response.body);
        return movesList.map((json) => Move.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get moves: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}