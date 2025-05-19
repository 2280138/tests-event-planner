import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final FirebaseFirestore firestore;

  // Add a constructor with an optional firestore parameter,
  // defaulting to the real FirebaseFirestore instance.
  CommentRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Use the firestore instance injected above instead of FirebaseFirestore.instance directly
  CollectionReference<Map<String, dynamic>> get _comments =>
      firestore.collection('comments');

  Stream<List<CommentModel>> getCommentsForPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print("Fetched comments: ${snapshot.docs.length}");  // Debugging line
      return snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    await _comments.add({
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("✅ Comment added to Firestore: $comment"); 
  }
}
