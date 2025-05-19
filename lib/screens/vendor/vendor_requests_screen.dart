import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class VendorRequestsScreen extends StatelessWidget {
  const VendorRequestsScreen({super.key});

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  Future<String> getOrganizerName(String organizerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(organizerId)
        .get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['displayName'] ?? 'Unknown Organizer';
    }
    return 'Unknown Organizer';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('vendorId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error loading requests"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No booking requests found."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              final Timestamp? selectedTimestamp = data['selectedDateTime'];
              final String formattedDateTime = selectedTimestamp != null
                  ? DateFormat.yMMMMd().add_jm().format(selectedTimestamp.toDate())
                  : 'No date selected';

              return FutureBuilder<String>(
                future: getOrganizerName(data['organizerId']),
                builder: (context, organizerSnapshot) {
                  final organizerName = organizerSnapshot.data ?? "Loading...";

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text("Category: ${data['category']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Vendor Name: ${data['vendorName']}"),
                          Text("Organizer: $organizerName"),
                          Text("Status: ${data['status']}"),
                          Text("Selected Date & Time: $formattedDateTime"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data['status'] == 'pending') ...[
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  updateBookingStatus(booking.id, 'accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  updateBookingStatus(booking.id, 'rejected'),
                            ),
                          ] else
                            Icon(
                              data['status'] == 'accepted'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: data['status'] == 'accepted'
                                  ? Colors.green
                                  : Colors.red,
                            )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
