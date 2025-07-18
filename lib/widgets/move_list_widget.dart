import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoveListWidget extends StatelessWidget {
  final List<String> moves;

  const MoveListWidget({
    Key? key,
    required this.moves,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: moves.length,
        itemBuilder: (context, index) {
          final moveNumber = (index ~/ 2) + 1;
          final isWhiteMove = index % 2 == 0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (isWhiteMove)
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$moveNumber.',
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isWhiteMove 
                        ? Colors.grey[100] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    moves[index],
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}