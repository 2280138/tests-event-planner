import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vendor_model.dart';

class VendorRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  VendorRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  Future<List<Map<String, dynamic>>> getVendorPosts(String userId) async {
    final snapshot = await firestore
        .collection('vendors')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<VendorModel>> getVendorItemsByUser(String userId) async {
    final snapshot = await firestore
        .collection('vendors')
        .where('user_id', isEqualTo: userId)
        .get();

    print('🟡 Found ${snapshot.docs.length} documents for userId: $userId');

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VendorModel.fromMap(data, doc.id);
    }).toList();
  }

  Future<void> deleteVendorPost(String postId) async {
    await firestore.collection('vendors').doc(postId).delete();
  }

  Future<void> updateVendorPost(String postId, Map<String, dynamic> updatedData) async {
    await firestore.collection('vendors').doc(postId).update(updatedData);
  }

  Future<List<Map<String, dynamic>>> getVendorsByCategory(String category) async {
    final snapshot = await firestore
        .collection('vendors')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> addVendorPost(Map<String, dynamic> vendorData) async {
    final userId = currentUserId;

    final vendorDataWithTimestamp = {
      ...vendorData,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await firestore.collection('vendors').add(vendorDataWithTimestamp);
  }

  Future<void> updateVendorPostById(String postId, Map<String, dynamic> vendorData) async {
    final userId = currentUserId;

    final updatedData = {
      ...vendorData,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await firestore.collection('vendors').doc(postId).update(updatedData);
  }
}
