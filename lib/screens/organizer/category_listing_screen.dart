import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vendor_detail_screen.dart';

class CategoryListingScreen extends StatelessWidget {
  final String category;

  const CategoryListingScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category Vendors')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vendors')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error loading data"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text("No vendors found in this category"));
          }

          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final imageUrl = data['image_url'];
             // final name = data['venue_name'] ?? data['business_name'] ?? 'No Name';



              return ListTile(
                leading: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
                )
                    : const Icon(Icons.image_not_supported),
                title: Text(
                  (data['business_name']?.toString().isNotEmpty ?? false)
                      ? data['business_name']
                      : (data['venue_name']?.toString().isNotEmpty ?? false)
                      ? data['venue_name']
                      : 'Unnamed',  style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                ),

                subtitle: Text(data['city'] ?? 'Unknown City'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorDetailScreen(
                        postId: posts[index].id,
                        postData: data,
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
