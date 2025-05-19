import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'blocs/auth_bloc/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/vendor_repository.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => VendorRepository(), // Provide VendorRepository here
      child: BlocProvider(
        create: (_) => AuthBloc(
          authRepository: AuthRepository(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            firestore: FirebaseFirestore.instance,
          ),
        ), // Provide AuthBloc with required dependencies
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Event Planner App',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
          ),
          home: SplashScreen(), // Start with splash screen
        ),
      ),
    );
  }
}
