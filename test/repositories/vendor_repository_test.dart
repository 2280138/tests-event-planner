import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:event_app/repositories/vendor_repository.dart';

import 'vendor_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late VendorRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserId');

    // ✅ No need for TestableVendorRepository — just pass mocks into constructor
    repository = VendorRepository(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  test('getVendorPosts returns vendor posts for a user', () async {
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    final mockQuery = MockQuery<Map<String, dynamic>>();
    final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    when(mockFirestore.collection('vendors')).thenReturn(mockCollection);
    when(mockCollection.where('userId', isEqualTo: 'testUserId')).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.docs).thenReturn([mockDoc]);
    when(mockDoc.data()).thenReturn({'business_name': 'Vendor A'});
    when(mockDoc.id).thenReturn('abc123');

    final result = await repository.getVendorPosts('testUserId');

    expect(result.length, 1);
    expect(result[0]['business_name'], 'Vendor A');
    expect(result[0]['id'], 'abc123');
  });

  test('deleteVendorPost deletes vendor document', () async {
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

    when(mockFirestore.collection('vendors')).thenReturn(mockCollection);
    when(mockCollection.doc('testId')).thenReturn(mockDocRef);
    when(mockDocRef.delete()).thenAnswer((_) async {});

    await repository.deleteVendorPost('testId');

    verify(mockDocRef.delete()).called(1);
  });

  test('addVendorPost adds a vendor document with userId', () async {
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();

    when(mockFirestore.collection('vendors')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => MockDocumentReference());

    await repository.addVendorPost({
      'business_name': 'New Vendor',
      'category': 'Catering',
    });

    verify(mockCollection.add(argThat(containsPair('userId', 'testUserId')))).called(1);
  });
}
