import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/game_info_widget.dart';
import '../widgets/move_list_widget.dart';
import '../widgets/game_controls_widget.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  ChessBoardController? _chessBoardController;

  @override
  void initState() {
    super.initState();
    _chessBoardController = ChessBoardController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shatranj'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showExitDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGameInfo,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                if (gameProvider.status == GameStatus.loading) {
                  return _buildLoadingScreen();
                }

                if (gameProvider.error != null) {
                  return _buildErrorScreen(gameProvider.error!);
                }

                if (gameProvider.currentGame == null) {
                  return _buildNoGameScreen();
                }

                final game = gameProvider.currentGame!;
                final isLandscape = constraints.maxWidth > constraints.maxHeight;

                final chessBoard = ChessBoard(
                  controller: _chessBoardController!,
                  boardColor: BoardColor.brown,
                  enableUserMoves: gameProvider.isMyTurn &&
                      gameProvider.status == GameStatus.active,
                  onMove: () => _handleMove(gameProvider),
                );

                final moveListAndControls = Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Calculate available space for move list
                            SizedBox(
                              height: (constraints.maxHeight - 80).clamp(100.0, double.infinity),
                              child: MoveListWidget(
                                moves: gameProvider.moves
                                    .map((e) => e.sanNotation)
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Controls at the bottom with fixed height
                            GameControlsWidget(
                              onResign: () => _showResignDialog(gameProvider),
                              onOfferDraw: () => _offerDraw(gameProvider),
                              gameStatus: gameProvider.status,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );

                return Column(
                  children: [
                    GameInfoWidget(game: game),
                    const SizedBox(height: 8),
                    Expanded(
                      child: isLandscape
                          ? Row(
                              children: [
                                Expanded(flex: 2, child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: chessBoard,
                                )),
                                Expanded(flex: 3, child: moveListAndControls),
                              ],
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: chessBoard,
                                ),
                                moveListAndControls,
                              ],
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleMove(GameProvider gameProvider) async {
    try {
      // Get the last move from the controller
      final lastMove = _chessBoardController?.game.history.last;
      if (lastMove != null) {
        await gameProvider.makeMove(lastMove as String);
      }
    } catch (error) {
      if (!mounted) return;
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Move failed: ${error.toString()}'),
        ),
      );
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading game...',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGameScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'No game found',
          style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[600]),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Are you sure you want to exit the game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showGameInfo() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final game = gameProvider.currentGame;

    if (game == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game ID: ${game.id}'),
            const SizedBox(height: 8),
            Text('Status: ${game.status}'),
            const SizedBox(height: 8),
            Text(
              'Time Control: ${game.timeControl ~/ 60}:${(game.timeControl % 60).toString().padLeft(2, '0')}',
            ),
            if (game.increment > 0)
              Text('Increment: +${game.increment} seconds'),
            const SizedBox(height: 8),
            Text('Current Turn: ${game.currentTurn}'),
            if (game.result != null) ...[
              const SizedBox(height: 8),
              Text('Result: ${game.result}'),
            ],
            if (game.termination != null) ...[
              const SizedBox(height: 8),
              Text('Termination: ${game.termination}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResignDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resign Game'),
        content: const Text(
          'Are you sure you want to resign? This will end the game.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameProvider.resignGame();
            },
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  void _offerDraw(GameProvider gameProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draw offer functionality not yet implemented'),
      ),
    );
  }

  @override
  void dispose() {
    _chessBoardController?.dispose();
    super.dispose();
  }
}