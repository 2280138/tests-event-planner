import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../repositories/comment_repository.dart';
import '../../widgets/comment_widget.dart';

class VendorListingDetailPage extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const VendorListingDetailPage({
    super.key,
    required this.postId,
    required this.postData,
  });



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
    final imageUrl = postData['image_url'];
   // final name = postData['venue_name'] ?? postData['business_name'] ?? 'Vendor Detail';

    final String? venueName = postData['venue_name'];
    final String? businessName = postData['business_name'];

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
            _buildDetailRow(Icons.location_city, 'City: ${postData['city'] ?? 'N/A'}'),
            _buildDetailRow(Icons.place, 'Address: ${postData['address'] ?? 'N/A'}'),
            _buildDetailRow(Icons.price_check, 'Price: PKR ${postData['price'] ?? 'N/A'}'),
            _buildDetailRow(Icons.inventory_2, 'Available Quantity: ${postData['quantity'] ?? 'N/A'}'),
            _buildDetailRow(Icons.person_outline, 'Contact Name: ${postData['contact_name'] ?? 'N/A'}'),
            _buildDetailRow(Icons.phone, 'Contact Phone: ${postData['contact_phone'] ?? 'N/A'}'),
            _buildDetailRow(Icons.email, 'Email: ${postData['email'] ?? 'N/A'}'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Description: ${postData['description'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            BlocProvider(
              create: (_) => CommentBloc(CommentRepository())..add(LoadComments(postId)),
              child: CommentWidget(postId: postId),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
