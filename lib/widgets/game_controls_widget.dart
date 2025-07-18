import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';

class GameControlsWidget extends StatelessWidget {
  final VoidCallback onResign;
  final VoidCallback onOfferDraw;
  final GameStatus gameStatus;

  const GameControlsWidget({
    Key? key,
    required this.onResign,
    required this.onOfferDraw,
    required this.gameStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (gameStatus == GameStatus.active) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: Text(
                'Resign',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[800],
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: onResign,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.handshake_outlined, size: 18),
              label: Text(
                'Offer Draw',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[800],
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: onOfferDraw,
            ),
          ],
          if (gameStatus == GameStatus.waiting) 
            Text(
              'Waiting for opponent...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          if (gameStatus == GameStatus.finished)
            Text(
              'Game finished',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}