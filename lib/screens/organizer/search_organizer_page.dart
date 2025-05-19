import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_listing_screen.dart';
import 'vendor_detail_screen.dart';

class SearchOrganizerPage extends StatefulWidget {
  const SearchOrganizerPage({Key? key}) : super(key: key);

  @override
  State<SearchOrganizerPage> createState() => _SearchOrganizerPageState();
}

class _SearchOrganizerPageState extends State<SearchOrganizerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final allVendors = await FirebaseFirestore.instance.collection('vendors').get();
    final lowerQuery = query.toLowerCase();

    final filtered = allVendors.docs.where((doc) {
      final data = doc.data();
      return [
        data['category'],
        data['city'],
        data['contact_name'],
        data['business_name'],
        data['address'],
        data['venue_name'],
      ].any((field) => field?.toString().toLowerCase().contains(lowerQuery) ?? false);
    }).map((doc) {
      return {
        'id': doc.id,
        'data': doc.data(),
      };
    }).toList();

    setState(() {
      _searchResults = filtered;
    });
  }

  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryListingScreen(category: category),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.category),
      label: Text(category),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () => _navigateToCategory(category),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.trim().isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Search Results',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _searchResults.isEmpty
            ? const Text("No matching vendors found.")
            : ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final postId = _searchResults[index]['id'];
            final data = _searchResults[index]['data'];
            final imageUrl = data['image_url'];

            return ListTile(
              leading: imageUrl != null
                  ? Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
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
                      postId: postId,
                      postData: data,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with Clear Button
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, service, city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _performSearch(value);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Explore Vendors by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildCategoryButton('Food'),
            const SizedBox(height: 12),
            _buildCategoryButton('Decor'),
            const SizedBox(height: 12),
            _buildCategoryButton('Venue'),
            const SizedBox(height: 24),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }
}