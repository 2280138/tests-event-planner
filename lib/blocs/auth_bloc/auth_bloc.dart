import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../models/user_model.dart'; // ✅ Import CustomUser model

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Check current session (App started)
    on<AppStarted>((event, emit) {
      final CustomUser? user = authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user)); // ✅ Now passing CustomUser
      } else {
        emit(Unauthenticated());
      }
    });

    // Handle Google Sign-In
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading()); // Show loading indicator while signing in
      try {
        print("Attempting Google Sign-In...");
        final CustomUser? user = await authRepository.signInWithGoogle();

        if (user != null) {
          print("Google Sign-In successful: ${user.displayName}"); // Debug log using displayName
          emit(Authenticated(user)); // ✅ Now passing CustomUser to Authenticated state
        } else {
          print("Google Sign-In failed: User is null"); // Debug log
          emit(Unauthenticated());
        }
      } catch (e) {
        print("Google Sign-In failed: ${e.toString()}"); // Debug log for error
        emit(AuthError("Sign in failed: ${e.toString()}"));
        emit(Unauthenticated());
      }
    });

    // Handle Logout
    on<LogoutRequested>((event, emit) async {
      print("Logging out..."); // Debug log for logout event
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }
}
