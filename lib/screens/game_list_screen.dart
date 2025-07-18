// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../services/api_service.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final ApiService _apiService = ApiService();
  List<Game> _games = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadGames();
  }
  
  Future<void> _loadGames() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final games = await _apiService.getGames(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Browse Games',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              accentColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Status Filter
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Status:',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('all', 'All'),
                          SizedBox(width: 8),
                          _buildStatusChip('waiting', 'Waiting'),
                          SizedBox(width: 8),
                          _buildStatusChip('active', 'Active'),
                          SizedBox(width: 8),
                          _buildStatusChip('finished', 'Finished'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Games List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Error loading games',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _error!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadGames,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _games.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No games found',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try refreshing or create a new game',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _games.length,
                              itemBuilder: (context, index) {
                                final game = _games[index];
                                return _buildGameCard(game, index);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    final isSelected = _selectedStatus == status;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        _loadGames();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : Theme.of(context).dividerColor,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameCard(Game game, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: accentColor.withOpacity(0.2),
      child: InkWell(
        onTap: game.status == 'waiting' ? () => _joinGame(game) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(game.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: accentColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${game.timeControl ~/ 60}:${(game.timeControl % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                        if (game.increment > 0)
                          Text(
                            ' +${game.increment}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: accentColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    'White Player',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  if (game.blackPlayerId != null)
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Black Player',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Waiting for player...',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Game ID: ${game.id}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Spacer(),
                  if (game.result != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Result: ${game.result}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 0.1).seconds).slideY(
      begin: 0.3,
      end: 0,
      duration: 0.6.seconds,
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'finished':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  void _joinGame(Game game) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Join Game',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game ID: ${game.id}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Time Control: ${game.timeControl ~/ 60}:${(game.timeControl % 60).toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  if (game.increment > 0)
                    Text(
                      'Increment: +${game.increment} seconds',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
              onChanged: (value) {
                // Store the name for joining
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement join game logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Join'),
          ),
        ],
      ),
    );
  }
}