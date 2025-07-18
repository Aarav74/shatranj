import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }
  
  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF8B4513);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              // ignore: deprecated_member_use
              primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 120,
                color: Colors.white,
              ).animate().scale(
                duration: 1.seconds,
                curve: Curves.elasticOut,
              ),
              SizedBox(height: 32),
              Text(
                'Shatranj',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(
                duration: 1.seconds,
                delay: 0.5.seconds,
              ),
              SizedBox(height: 16),
              Text(
                'The Royal Game of Chess',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(
                duration: 1.seconds,
                delay: 1.seconds,
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ).animate().fadeIn(
                duration: 1.seconds,
                delay: 1.5.seconds,
              ),
            ],
          ),
        ),
      ),
    );
  }
}