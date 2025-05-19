import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createBooking(Booking booking) {
    return firestore.collection('bookings').add(booking.toMap());
  }

  Stream<List<Booking>> getBookingsForOrganizer(String organizerId) {
    return firestore
        .collection('bookings')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Booking.fromMap(data, doc.id);
            }).toList());
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) {
    return firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': newStatus});
  }
}
