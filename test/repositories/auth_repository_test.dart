import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:event_app/repositories/auth_repository.dart';

// GENERATED MOCK CLASSES
import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseFirestore,
  UserCredential,
  User,
  CollectionReference,
  DocumentReference,
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;

  late AuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuth = MockGoogleSignInAuthentication();
    mockFirestore = MockFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoc = MockDocumentReference<Map<String, dynamic>>();

    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      firestore: mockFirestore,
    );
  });

  test('Google sign-in should return CustomUser on success', () async {
    // Stub Google Sign-In
    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuth);
    when(mockGoogleSignInAuth.accessToken).thenReturn('fake_access_token');
    when(mockGoogleSignInAuth.idToken).thenReturn('fake_id_token');

    // Stub Firebase Auth
    when(mockFirebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('123');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.photoURL).thenReturn('http://photo.com/pic.jpg');

    // Stub Firestore
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('123')).thenReturn(mockDoc);
    when(mockDoc.set(any)).thenAnswer((_) async => {});

    // Act
    final result = await authRepository.signInWithGoogle();

    // Assert
    expect(result, isNotNull);
    expect(result?.uid, '123');
    expect(result?.email, 'test@example.com');
    expect(result?.displayName, 'Test User');
  });

    //signout
  test('signOut should sign out from Firebase and Google', () async {
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async {
      return null;
    });
    await authRepository.signOut();

    verify(mockFirebaseAuth.signOut()).called(1);
    verify(mockGoogleSignIn.signOut()).called(1);
  });

  test('getCurrentUser returns CustomUser if logged in', () {
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('123');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.photoURL).thenReturn('http://photo.com/pic.jpg');

    final user = authRepository.getCurrentUser();

    expect(user, isNotNull);
    expect(user?.uid, '123');
  });
}

