// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import 'game_screen.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _JoinGameScreenState createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameIdController = TextEditingController();
  final _playerNameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join Game',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: Container(
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
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.login,
                            size: 48,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Join Game',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter the game ID to join an existing match',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 0.8.seconds).slideY(
                    begin: -0.3,
                    end: 0,
                    duration: 0.8.seconds,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Game ID Input
                  Text(
                    'Game ID',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 0.2.seconds),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _gameIdController,
                    decoration: InputDecoration(
                      hintText: 'Enter game ID',
                      prefixIcon: Icon(Icons.tag, color: accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a game ID';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 0.3.seconds).slideX(
                    begin: -0.3,
                    end: 0,
                    duration: 0.6.seconds,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Player Name Input
                  Text(
                    'Player Name',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 0.4.seconds),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _playerNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person, color: accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 0.5.seconds).slideX(
                    begin: 0.3,
                    end: 0,
                    duration: 0.6.seconds,
                  ),
                  
                  Spacer(),
                  
                  // Join Button
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return ElevatedButton(
                        onPressed: gameProvider.status == GameStatus.loading
                            ? null
                            : () => _joinGame(context, gameProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: accentColor.withOpacity(0.3),
                        ),
                        child: gameProvider.status == GameStatus.loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Joining Game...',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Join Game',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ).animate().fadeIn(delay: 0.6.seconds).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 0.6.seconds,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Footer
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Make sure you have the correct game ID from the host',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 0.8.seconds),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _joinGame(BuildContext context, GameProvider gameProvider) async {
    if (_formKey.currentState!.validate()) {
      try {
        await gameProvider.joinGame(
          _gameIdController.text,
          _playerNameController.text,
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join game: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _gameIdController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }
}