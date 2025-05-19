import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:event_app/models/booking_model.dart';
import 'package:event_app/repositories/booking_repository.dart';

import 'booking_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
])


void main() {
  
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late BookingRepository bookingRepository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    bookingRepository = BookingRepository(firestore: mockFirestore); // ✅ injected here
  });

  test('createBooking adds booking to Firestore', () async {
    final booking = Booking(
      id: '1',
      organizerId: 'org123',
      vendorId: 'vendor456',
      vendorCategory: 'Catering',
      vendorName: 'ABC Caterers',
      status: 'pending',
      selectedDateTime: DateTime.now(),
    );


    when(mockFirestore.collection('bookings')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await bookingRepository.createBooking(booking);

    verify(mockFirestore.collection('bookings')).called(1);
    verify(mockCollection.add(booking.toMap())).called(1);
  });

  test('getBookingsForOrganizer returns list of bookings', () async {
  final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    final bookingMap = {
      'organizerId': 'org123',
      'vendorId': 'vendor456',
      'vendorCategory': 'Catering',
      'vendorName': 'ABC Caterers',
      'status': 'pending',
      'selectedDateTime': Timestamp.fromDate(DateTime.now()),
    };


    when(mockFirestore.collection('bookings')).thenReturn(mockCollection);
    when(mockCollection.where('organizerId', isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockCollection);
    when(mockCollection.snapshots())
        .thenAnswer((_) => Stream.fromIterable([mockSnapshot]));
    when(mockSnapshot.docs).thenReturn([mockDoc]);
    when(mockDoc.id).thenReturn('1');
    when(mockDoc.data()).thenReturn(bookingMap);

    final stream = bookingRepository.getBookingsForOrganizer('org123');

    await expectLater(stream, emits(isA<List<Booking>>()));
  });

  test('updateBookingStatus updates booking status', () async {
    when(mockFirestore.collection('bookings')).thenReturn(mockCollection);
    when(mockCollection.doc('1')).thenReturn(mockDocument);
    when(mockDocument.update({'status': 'confirmed'})).thenAnswer((_) async {});

    await bookingRepository.updateBookingStatus('1', 'confirmed');

    verify(mockFirestore.collection('bookings')).called(1);
    verify(mockCollection.doc('1')).called(1);
    verify(mockDocument.update({'status': 'confirmed'})).called(1);
  });
}
