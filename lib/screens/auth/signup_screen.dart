import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc/auth_bloc.dart';
import '../../blocs/auth_bloc/auth_event.dart';
import '../../blocs/auth_bloc/auth_state.dart';
import '../role_selection/role_selection_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            // Your Image
            Image.asset("assets/signup.PNG"),

            SizedBox(height: 10),

            // Texts for the header
            Text(
              "Unlock the Future of",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Event Booking App",
              style: TextStyle(
                color: Color(0xff6351ec),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30),

            // Tagline
            Text(
              "Discover, book and experience unforgettable moments effortlessly!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 20,
              ),
            ),

            SizedBox(height: 50),

            // BlocConsumer for the Google SignIn with Firebase and AuthBloc
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          "Registered Successfully",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Keep text readable
                        ),
                      ),
                      backgroundColor: Colors.green, // Green background
                    ),
                  );
                  // Navigate to Role Selection Screen after successful authentication
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return GestureDetector(
                  onTap: () {
                    // Triggering Google SignIn via the AuthBloc
                    context.read<AuthBloc>().add(GoogleSignInRequested());
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xff6351ec),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image.asset(
                        //   "assets/google.PNG",
                        //   height: 30,
                        //   width: 30,
                        //   fit: BoxFit.cover,
                        // ),

                        Icon(
                          Icons.login, // Replacing the image with the login icon
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Sign in with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
