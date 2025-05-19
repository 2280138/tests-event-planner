import 'package:flutter/material.dart';
import '../vendor/vendor_list_screen.dart'; // Ensure this file exists

class CategoryListingScreen extends StatelessWidget {
  final List<String> categories = ['Food', 'Decor', 'Venue'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            child: ListTile(
              title: Text(category),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VendorListScreen(category: category), // Corrected screen
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
