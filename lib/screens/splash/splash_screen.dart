import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Importing required files for authentication and navigation
import '../../blocs/auth_bloc/auth_bloc.dart';
import '../auth/signup_screen.dart';
import '../../blocs/auth_bloc/auth_event.dart';
import '../../blocs/auth_bloc/auth_state.dart';
import '../role_selection/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for splash animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2800), // Total duration of the animation
    );

    // Scaling animation for the logo image (zoom-in effect)
    _scaleAnimation = Tween<double>(begin: 1.5, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    // Start the animation
    _controller.forward();

    // Trigger the authentication check on app start
    context.read<AuthBloc>().add(AppStarted());

    // Delay for 8 seconds before navigating to the next screen
    Timer(Duration(seconds: 8), () {
      final state = context.read<AuthBloc>().state;

      // Navigate to RoleSelection if already authenticated
      if (state is Authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
        );
      } else {
        // Navigate to Signup screen if not authenticated
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignupScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose the animation controller to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient for the splash screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Center the animated content
        child: Center(
          // Fade animation for the entire column
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                // Logo with scaling animation and shadow
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.shade200,
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/logo.png", // Logo image path
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover, // Make sure the image fits in a circle
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25), // Space between logo and text

                // Animated typewriter text
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Event Planner App\nYour Event, Our Plan!',
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      speed: Duration(milliseconds: 100), // Typing speed
                    ),
                  ],
                  totalRepeatCount: 1, // Run animation once
                ),

                const SizedBox(height: 35), // Space between text and loader

                // Circular loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}