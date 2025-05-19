import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../repositories/comment_repository.dart';
import '../../widgets/comment_widget.dart';

class VendorDetailScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const VendorDetailScreen({
    super.key,
    required this.postId,
    required this.postData,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _bookVendor(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (currentUser.uid == widget.postData['user_id']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ You cannot book your own vendor listing.")),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📅 Please select a date and time first.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('bookings').add({
      'organizerId': currentUser.uid,
      'vendorId': widget.postData['user_id'],
      'postId': widget.postId,
      'category': widget.postData['category'],
      'vendorName': (widget.postData['business_name'] != null && widget.postData['business_name'].toString().isNotEmpty)
          ? widget.postData['business_name']
          : widget.postData['venue_name'],

      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'selectedDateTime': _selectedDateTime,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Booking Request Sent (Pending Approval)')),
    );

    Navigator.pop(context);
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.postData['image_url'];
   // final name = widget.postData['venue_name'] ?? widget.postData['business_name'] ?? 'Vendor Detail';


    final String? venueName = widget.postData['venue_name'];
    final String? businessName = widget.postData['business_name'];

    final name = (businessName != null && businessName.isNotEmpty)
        ? businessName
        : (venueName != null && venueName.isNotEmpty)
        ? venueName
        : 'Vendor Detail';


    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            Text('Details', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildDetailRow(Icons.person, 'Name: $name'),
            _buildDetailRow(Icons.location_city, 'City: ${widget.postData['city'] ?? 'N/A'}'),
            _buildDetailRow(Icons.place, 'Address: ${widget.postData['address'] ?? 'N/A'}'),
            _buildDetailRow(Icons.price_check, 'Price: PKR ${widget.postData['price'] ?? 'N/A'}'),
            _buildDetailRow(Icons.inventory_2, 'Available Quantity: ${widget.postData['quantity'] ?? 'N/A'}'),
            _buildDetailRow(Icons.person_outline, 'Contact Name: ${widget.postData['contact_name'] ?? 'N/A'}'),
            _buildDetailRow(Icons.phone, 'Contact Phone: ${widget.postData['contact_phone'] ?? 'N/A'}'),
            _buildDetailRow(Icons.email, 'Email: ${widget.postData['email'] ?? 'N/A'}'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 20,color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Description: ${widget.postData['description'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 30),

            /// 📅 Select Date & Time Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _selectDateTime(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Date & Time'),
              ),
            ),

            if (_selectedDateTime != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Selected: ${_selectedDateTime!.toLocal()}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],

            const SizedBox(height: 30),

            /// 🔁 Comments Section
            BlocProvider(
              create: (_) => CommentBloc(CommentRepository())..add(LoadComments(widget.postId)),
              child: CommentWidget(postId: widget.postId),
            ),

            const SizedBox(height: 30),

            /// 📌 Book Vendor Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _bookVendor(context),
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Book Vendor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
