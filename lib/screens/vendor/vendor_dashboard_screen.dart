import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc/auth_bloc.dart';
import '../../blocs/auth_bloc/auth_event.dart';
import '../../models/user_model.dart';
import '../auth/signup_screen.dart';
import '../role_selection/role_selection_screen.dart';
import 'vendor_form_screen.dart';
import 'vendor_items_screen.dart';
import 'vendor_requests_screen.dart';
import '../../blocs/vendor/vendor_bloc.dart';
import '../../repositories/vendor_repository.dart';

class VendorDashboardScreen extends StatefulWidget {
  final CustomUser user;

  const VendorDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 1;

  Future<List<Map<String, dynamic>>> _fetchAcceptedBookingsWithDetails() async {
    final now = DateTime.now();

    final bookingSnapshots = await FirebaseFirestore.instance
        .collection('bookings')
        .where('vendorId', isEqualTo: widget.user.uid)
        .where('status', isEqualTo: 'accepted')
        .get();

    List<Map<String, dynamic>> bookingsData = [];

    for (final doc in bookingSnapshots.docs) {
      final data = doc.data();
      final selectedDateTime = (data['selectedDateTime'] as Timestamp).toDate();
      final postId = data['postId'];
      final organizerId = data['organizerId'];

      // Fetch vendor post data
      final vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(postId).get();
      if (!vendorDoc.exists) continue;

      final vendorData = vendorDoc.data()!;
      final vendorImageUrl = vendorData['image_url'] ?? '';
      final category = vendorData['category'] ?? 'Uncategorized';

      // Fetch organizer user data
      final organizerDoc = await FirebaseFirestore.instance.collection('users').doc(organizerId).get();
      final organizerData = organizerDoc.data();
      final organizerName = organizerData?['displayName'] ?? 'Unknown';

      bookingsData.add({
        'vendorImageUrl': vendorImageUrl,
        'category': category,
        'vendorName': data['vendorName'] ?? 'Vendor',
        'organizerName': organizerName,
        'selectedDateTime': selectedDateTime,
      });
    }

    // Sort upcoming first
    bookingsData.sort((a, b) {
      return (a['selectedDateTime'] as DateTime).compareTo(b['selectedDateTime'] as DateTime);
    });

    return bookingsData;
  }


  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen()),
          (route) => false,
    );
  }

  List<Widget> get _pages => [
    VendorItemsScreen(userId: widget.user.uid),
    _buildDashboardContent(),
    BlocProvider(
      create: (_) => VendorBloc(vendorRepository: context.read<VendorRepository>()),
      child: VendorFormScreen(userId: widget.user.uid),
    ),
    const VendorRequestsScreen(),
  ];

// Replace inside _buildDashboardContent()
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hey, ${widget.user.displayName} 👋',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          Text(
            '“Great service sells itself – let your work speak.”',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.deepPurpleAccent),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to your Vendor Hub',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage listings, handle bookings, and grow your presence with ease.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          Text(
            'Your Accepted Bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAcceptedBookingsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No bookings yet.'));
                }

                final bookings = snapshot.data!;
                final now = DateTime.now();

                final upcomingBookings = bookings.where((b) => (b['selectedDateTime'] as DateTime).isAfter(now)).toList();
                final doneBookings = bookings.where((b) => (b['selectedDateTime'] as DateTime).isBefore(now)).toList();

                final allBookings = [...upcomingBookings, ...doneBookings];

                return ListView.builder(
                  itemCount: allBookings.length,
                  itemBuilder: (context, index) {
                    final booking = allBookings[index];
                    final vendorImageUrl = booking['vendorImageUrl'] ?? '';
                    final category = booking['category'];
                    final vendorName = booking['vendorName'];
                    final organizerName = booking['organizerName'];
                    final selectedDateTime = booking['selectedDateTime'];
                    final isUpcoming = selectedDateTime.isAfter(DateTime.now());
                    final formattedDate = "${selectedDateTime.toLocal().toString().split(' ')[0]}";
                    final formattedTime = TimeOfDay.fromDateTime(selectedDateTime).format(context);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  vendorImageUrl.isNotEmpty
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      vendorImageUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 5),
                                  Text(vendorName, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text('Organizer: $organizerName', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                  const SizedBox(height: 5),
                                  Text('$formattedDate at $formattedTime', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isUpcoming ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isUpcoming ? 'Upcoming' : 'Done',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF3E5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Vendor Space', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.w500,)
          ),
          centerTitle: true,
          backgroundColor:Colors.deepPurple,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body: _currentIndex < 4 ? _pages[_currentIndex] : Container(),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFFF3E5F5),
        color: Colors.deepPurple,
        buttonBackgroundColor: Colors.orange,
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: _currentIndex,
        items: const [
          Icon(Icons.list, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.add_circle, size: 30, color: Colors.white),
          Icon(Icons.book_online, size: 30, color: Colors.white),
          Icon(Icons.swap_horiz, size: 30, color: Colors.white), // Added the swap icon
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Check if the swap icon is tapped (index = 4) and navigate to RoleSelectionScreen
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
            );
          }
        },
      ),

    );
  }
}