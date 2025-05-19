import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with Google
  Future<CustomUser?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      CustomUser customUser = CustomUser(
        uid: user.uid,
        displayName: user.displayName ?? 'No Name',
        email: user.email ?? 'No Email',
        photoUrl: user.photoURL ?? '',
      );

      await _saveUserToFirestore(customUser);
      return customUser;
    } catch (e) {
      print("Error during Google Sign-In: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("Error during sign out: ${e.toString()}");
      rethrow;
    }
  }

  CustomUser? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return CustomUser(
      uid: user.uid,
      displayName: user.displayName ?? 'No Name',
      email: user.email ?? 'No Email',
      photoUrl: user.photoURL ?? '',
    );
  }

  Future<void> _saveUserToFirestore(CustomUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoUrl,
      });
    } catch (e) {
      print("Error saving user to Firestore: ${e.toString()}");
      rethrow;
    }
  }
}
