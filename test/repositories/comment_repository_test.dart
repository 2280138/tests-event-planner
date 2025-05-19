import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/repositories/comment_repository.dart';

import 'comment_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late CommentRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    repository = CommentRepository(firestore: mockFirestore);
  });

  test('✅ addComment should call Firestore add with correct data', () async {
    when(mockFirestore.collection('comments')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await repository.addComment(
      postId: 'post123',
      userId: 'user123',
      userName: 'Test User',
      comment: 'This is a test comment',
    );

    verify(mockCollection.add(argThat(
      containsPair('comment', 'This is a test comment'),
    ))).called(1);
  });

  test('⚠️ addComment with empty comment should still call Firestore add', () async {
    when(mockFirestore.collection('comments')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await repository.addComment(
      postId: 'post123',
      userId: 'user123',
      userName: 'Test User',
      comment: '', // empty comment
    );

    verify(mockCollection.add(argThat(
      containsPair('comment', ''),
    ))).called(1);
  });

  test('⚠️ addComment with all empty fields should still call Firestore add', () async {
    when(mockFirestore.collection('comments')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await repository.addComment(
      postId: '',
      userId: '',
      userName: '',
      comment: '',
    );

    verify(mockCollection.add(argThat(
      containsPair('comment', ''),
    ))).called(1);
  });

  test('❌ addComment should throw if Firestore add fails', () async {
    when(mockFirestore.collection('comments')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenThrow(Exception('Firestore error'));

    expect(
          () async => await repository.addComment(
        postId: 'post123',
        userId: 'user123',
        userName: 'Test User',
        comment: 'This will fail',
      ),
      throwsA(isA<Exception>()),
    );
  });
}