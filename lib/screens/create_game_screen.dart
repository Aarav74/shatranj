// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shatranj/models/game_models.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  int _timeControl = 10; // minutes
  int _increment = 0; // seconds

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Game',
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
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
                            Icons.add_circle_outline,
                            size: 48,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Create a New Chess Game',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Set up your game preferences and start playing',
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
                  
                  // Player Name Input
                  Text(
                    'Player Name',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 0.2.seconds),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _playerNameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                      prefixIcon: Icon(Icons.person, color: accentColor),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 0.3.seconds).slideX(
                    begin: -0.3,
                    end: 0,
                    duration: 0.6.seconds,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Time Control Section
                  Text(
                    'Time Control',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 0.4.seconds),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _timeControl,
                          items: [1, 3, 5, 10, 15, 30]
                              .map((minutes) => DropdownMenuItem(
                                    value: minutes,
                                    child: Text('$minutes minutes'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _timeControl = value!;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: accentColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            labelText: 'Minutes',
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _increment,
                          items: [0, 1, 2, 3, 5, 10]
                              .map((seconds) => DropdownMenuItem(
                                    value: seconds,
                                    child: Text('+$seconds seconds'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _increment = value!;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: accentColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            labelText: 'Increment',
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 0.5.seconds).slideX(
                    begin: 0.3,
                    end: 0,
                    duration: 0.6.seconds,
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Create Game Button
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return ElevatedButton(
                        onPressed: gameProvider.status == GameStatus.loading
                            ? null
                            : () => _createGame(gameProvider),
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
                                    'Creating Game...',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Create Game',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
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
                      'Your game will be available for others to join',
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

  Future<void> _createGame(GameProvider gameProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }


    try {
      await gameProvider.createGame(
        playerName: _playerNameController.text,
        timeControl: _timeControl * 60,
        increment: _increment,
      );
      
      
      // Check if there's an error in the provider
      if (gameProvider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${gameProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Check if the game was created successfully
      if (gameProvider.currentGame != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const GameScreen(),
            ),
          );
        }
      } else {
        // Show error if game creation failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create game. Current game is null. Status: ${gameProvider.status}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors during game creation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exception: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}