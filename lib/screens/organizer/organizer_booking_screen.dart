import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../services/booking_service.dart';

class OrganizerBookingScreen extends StatelessWidget {
  final String organizerId;
  final BookingService bookingService = BookingService();

   OrganizerBookingScreen({super.key, required this.organizerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Booking Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingService.getBookingsForOrganizer(organizerId), // use service
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading bookings.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookings = snapshot.data!.docs;

          if (allBookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final now = DateTime.now();

          // Separate bookings by status
          final pendingBookings = allBookings
              .where((doc) => (doc['status'] == 'pending'))
              .toList();

          final acceptedBookings = allBookings
              .where((doc) => (doc['status'] == 'accepted'))
              .toList();

          final rejectedBookings = allBookings
              .where((doc) => (doc['status'] == 'rejected'))
              .toList();

          // Sort acceptedBookings: Upcoming (nearest first), then Done (latest last)
          acceptedBookings.sort((a, b) {
            final dateA = (a['selectedDateTime'] as Timestamp?)?.toDate();
            final dateB = (b['selectedDateTime'] as Timestamp?)?.toDate();
            if (dateA == null || dateB == null) return 0;

            final isDoneA = dateA.isBefore(now);
            final isDoneB = dateB.isBefore(now);

            if (isDoneA && !isDoneB) return 1;
            if (!isDoneA && isDoneB) return -1;

            return dateA.compareTo(dateB); // Nearest upcoming or latest done
          });

          final bookings = [
            ...pendingBookings,
            ...acceptedBookings,
            ...rejectedBookings,
          ];

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              final String status = data['status'];
              final Timestamp? selectedTimestamp = data['selectedDateTime'];
              final DateTime? bookingDate =
              selectedTimestamp?.toDate();
              final String formattedDateTime = bookingDate != null
                  ? DateFormat.yMMMMd().add_jm().format(bookingDate)
                  : 'No date selected';

              // Determine card color
              Color? cardColor;
              if (status == 'accepted') {
                cardColor = Colors.green[100];
              } else if (status == 'rejected') {
                cardColor = Colors.red[100];
              }

              // Badge for accepted bookings
              String? badgeText;
              if (status == 'accepted' && bookingDate != null) {
                badgeText = bookingDate.isBefore(now) ? 'Done' : 'Upcoming';
              }

              return Card(
                margin: const EdgeInsets.all(10),
                color: cardColor,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Category: ${data['category']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vendor: ${data['vendorName']}'),
                            Text('Status: ${status[0].toUpperCase()}${status.substring(1)}'),
                            Text('Selected Date & Time: $formattedDateTime'),
                            const SizedBox(height: 8),
                            if (status == 'pending')
                              ElevatedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Cancel Booking'),
                                      content: const Text(
                                          'Are you sure you want to cancel this booking? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await bookingService.deleteBooking(booking.id);


                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Your Booking is successfully cancelled.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to delete booking: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Cancel Booking'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Badge positioned top-right
                    if (badgeText != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeText == 'Done' ? Colors.grey : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
