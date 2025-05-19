import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Stream<QuerySnapshot> getBookingsForOrganizer(String organizerId) {
    return firestore
        .collection('bookings')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots();
  }

  Future<void> deleteBooking(String bookingId) async {
    await firestore.collection('bookings').doc(bookingId).delete();
  }
}
