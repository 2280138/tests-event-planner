import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:event_app/services/booking_service.dart'; 

import 'booking_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
])
void main() {
  late BookingService service;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    service = TestableBookingService(mockFirestore);
  });

  test('deleteBooking deletes booking document', () async {
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

    when(mockFirestore.collection('bookings')).thenReturn(mockCollection);
    when(mockCollection.doc('booking123')).thenReturn(mockDocRef);
    when(mockDocRef.delete()).thenAnswer((_) async {});

    await service.deleteBooking('booking123');

    verify(mockDocRef.delete()).called(1);
  });
}

class TestableBookingService extends BookingService {
  final FirebaseFirestore testFirestore;

  TestableBookingService(this.testFirestore);

  @override
  FirebaseFirestore get firestore => testFirestore;
}
