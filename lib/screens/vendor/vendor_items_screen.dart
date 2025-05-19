import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_app/blocs/vendor/vendor_bloc.dart';
import 'package:event_app/blocs/vendor/vendor_event.dart';
import 'package:event_app/blocs/vendor/vendor_state.dart';
import 'package:event_app/models/vendor_model.dart';
import 'package:event_app/repositories/vendor_repository.dart';
import 'package:event_app/screens/vendor/vendor_listing_detail_page.dart';

import 'edit_vendor_form.dart'; // ✅ Add this import

class VendorItemsScreen extends StatelessWidget {
  final String userId;

  const VendorItemsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🟢 User ID passed to VendorItemsScreen: $userId');

    return RepositoryProvider(
      create: (_) => VendorRepository(),
      child: BlocProvider(
        create: (context) {
          print('🟢 User ID passed to LoadVendorItemsByUserEvent: $userId');
          return VendorBloc(
            vendorRepository: RepositoryProvider.of<VendorRepository>(context),
          )..add(LoadVendorItemsByUserEvent(userId));
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Your Services Portfolio')),
          body: BlocBuilder<VendorBloc, VendorState>(
            builder: (context, state) {
              if (state is VendorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is VendorLoaded) {
                final List<VendorModel> posts = state.vendors;
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts found.'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: post.imageUrl.isNotEmpty
                              ? Image.network(
                            post.imageUrl,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 50);
                            },
                          )
                              : const Icon(Icons.image),
                          title: Text(
                            (post.businessName?.isNotEmpty ?? false)
                                ? post.businessName!
                                : (post.venueName ?? 'Unnamed Venue'),
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            post.category,
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final vendorBloc = BlocProvider.of<VendorBloc>(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: vendorBloc,
                            child: VendorEditFormScreen(vendor: post),
                          ),
                        ),
                      );

                    },
                    ),
                    IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                    _showDeleteDialog(context, post.id);
                    },
                    ),
                    ],
                    ),

                    onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorListingDetailPage(
                                  postId: post.id,
                                  postData: {
                                    'business_name': post.businessName,
                                    'venue_name': post.venueName,
                                    'city': post.city,
                                    'address': post.address,
                                    'price': post.price,
                                    'quantity': post.quantity,
                                    'contact_name': post.contactName,
                                    'contact_phone': post.contactPhone,
                                    'email': post.email,
                                    'description': post.description,
                                    'image_url': post.imageUrl,
                                    'category': post.category,
                                    'user_id': post.userId,
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              } else if (state is VendorError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                return const Center(child: Text('Unexpected state.'));
              }
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<VendorBloc>(context).vendorRepository.deleteVendorPost(postId);
              Navigator.of(context).pop();
              BlocProvider.of<VendorBloc>(context).add(LoadVendorItemsByUserEvent(userId));
            },
            child: const Text('Delete'),
          ),

        ],
      ),
    );
  }
}
