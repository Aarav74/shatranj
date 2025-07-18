// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'create_game_screen.dart';
import 'join_game_screen.dart';
import 'game_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shatranj',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.setThemeMode(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      isDark ? Theme.of(context).primaryColor.withOpacity(0.1) : const Color(0xFF8B4513).withOpacity(0.1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Hero Section
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Custom Chess Logo
                              _buildChessLogo(context),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome to Shatranj',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Challenge players worldwide in the ultimate game of strategy',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 1.seconds).slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 1.seconds,
                          curve: Curves.easeOut,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Menu Options - Now scrollable if needed
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.6,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMenuButton(
                                  context,
                                  icon: Icons.add_circle_outline,
                                  title: 'Create Game',
                                  subtitle: 'Start a new chess match',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CreateGameScreen()),
                                    );
                                  },
                                ).animate().fadeIn(delay: 0.2.seconds).slideX(
                                  begin: -0.3,
                                  end: 0,
                                  duration: 0.8.seconds,
                                  curve: Curves.easeOut,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildMenuButton(
                                  context,
                                  icon: Icons.login,
                                  title: 'Join Game',
                                  subtitle: 'Enter a game with room code',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => JoinGameScreen()),
                                    );
                                  },
                                ).animate().fadeIn(delay: 0.4.seconds).slideX(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 0.8.seconds,
                                  curve: Curves.easeOut,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildMenuButton(
                                  context,
                                  icon: Icons.list,
                                  title: 'Browse Games',
                                  subtitle: 'View active and waiting games',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const GameListScreen()),
                                    );
                                  },
                                ).animate().fadeIn(delay: 0.6.seconds).slideX(
                                  begin: -0.3,
                                  end: 0,
                                  duration: 0.8.seconds,
                                  curve: Curves.easeOut,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Footer
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Crafted with ♟️ for chess enthusiasts',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().fadeIn(delay: 1.seconds),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChessLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use brown color for light theme, keep original primary color for dark theme
    final logoColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor.withOpacity(0.8),
            logoColor.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: logoColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Chessboard pattern background
          CustomPaint(
            size: const Size(80, 80),
            painter: ChessboardPainter(isDark: isDark),
          ),
          // King and Knight silhouette
          CustomPaint(
            size: const Size(60, 60),
            painter: ChessPiecesPainter(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    return Card(
      elevation: 8,
      shadowColor: accentColor.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the chessboard background
class ChessboardPainter extends CustomPainter {
  final bool isDark;

  ChessboardPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final squareSize = size.width / 8;
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if ((i + j) % 2 == 0) {
          paint.color = isDark ? Colors.white24 : Colors.black12;
        } else {
          paint.color = isDark ? Colors.white12 : Colors.black26;
        }
        
        canvas.drawRect(
          Rect.fromLTWH(
            i * squareSize,
            j * squareSize,
            squareSize,
            squareSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for chess pieces silhouette
class ChessPiecesPainter extends CustomPainter {
  final Color color;

  ChessPiecesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw King silhouette (left side)
    _drawKing(canvas, paint, Offset(center.dx - 12, center.dy), size.width * 0.25);
    
    // Draw Knight silhouette (right side)
    _drawKnight(canvas, paint, Offset(center.dx + 12, center.dy), size.width * 0.25);
  }

  void _drawKing(Canvas canvas, Paint paint, Offset center, double scale) {
    final path = Path();
    
    // King crown
    path.moveTo(center.dx - 8 * scale / 10, center.dy - 8 * scale / 10);
    path.lineTo(center.dx - 4 * scale / 10, center.dy - 12 * scale / 10);
    path.lineTo(center.dx, center.dy - 10 * scale / 10);
    path.lineTo(center.dx + 4 * scale / 10, center.dy - 12 * scale / 10);
    path.lineTo(center.dx + 8 * scale / 10, center.dy - 8 * scale / 10);
    
    // King body
    path.lineTo(center.dx + 6 * scale / 10, center.dy - 4 * scale / 10);
    path.lineTo(center.dx + 6 * scale / 10, center.dy + 4 * scale / 10);
    path.lineTo(center.dx + 8 * scale / 10, center.dy + 8 * scale / 10);
    path.lineTo(center.dx - 8 * scale / 10, center.dy + 8 * scale / 10);
    path.lineTo(center.dx - 6 * scale / 10, center.dy + 4 * scale / 10);
    path.lineTo(center.dx - 6 * scale / 10, center.dy - 4 * scale / 10);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawKnight(Canvas canvas, Paint paint, Offset center, double scale) {
    final path = Path();
    
    // Knight horse head silhouette
    path.moveTo(center.dx - 6 * scale / 10, center.dy + 8 * scale / 10);
    path.lineTo(center.dx - 8 * scale / 10, center.dy + 2 * scale / 10);
    path.lineTo(center.dx - 6 * scale / 10, center.dy - 4 * scale / 10);
    path.lineTo(center.dx - 2 * scale / 10, center.dy - 8 * scale / 10);
    path.lineTo(center.dx + 2 * scale / 10, center.dy - 10 * scale / 10);
    path.lineTo(center.dx + 6 * scale / 10, center.dy - 8 * scale / 10);
    path.lineTo(center.dx + 8 * scale / 10, center.dy - 4 * scale / 10);
    path.lineTo(center.dx + 6 * scale / 10, center.dy);
    path.lineTo(center.dx + 8 * scale / 10, center.dy + 4 * scale / 10);
    path.lineTo(center.dx + 6 * scale / 10, center.dy + 8 * scale / 10);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}