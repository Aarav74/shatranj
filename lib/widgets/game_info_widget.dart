// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';

class GameInfoWidget extends StatelessWidget {
  final Game game;
  
  const GameInfoWidget({super.key, required this.game});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Game Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(gameProvider.status as String),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(gameProvider.status as String),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Player Information
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerInfo(
                      context,
                      'White',
                      gameProvider.whiteTimeLeft,
                      game.currentTurn == 'white',
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'VS',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildPlayerInfo(
                      context,
                      'Black',
                      gameProvider.blackTimeLeft,
                      game.currentTurn == 'black',
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Time Control Information
              _buildTimeControlInfo(context, game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfo(BuildContext context, String playerColor, int timeLeft, bool isCurrentTurn) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTurn 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            playerColor,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: playerColor == 'White' ? Colors.grey[800] : Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _formatTime(timeLeft),
            style: GoogleFonts.robotoMono(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: timeLeft < 30 ? Colors.red : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeControlInfo(BuildContext context, Game game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timer,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(width: 8),
        Text(
          'Time Control: ${game.timeControl ~/ 60}+${game.increment}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'finished':
        return Colors.purple;
      case 'aborted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return 'Waiting for opponent';
      case 'active':
        return 'Game in progress';
      case 'finished':
        return 'Game finished';
      case 'aborted':
        return 'Game aborted';
      default:
        return status;
    }
  }
}