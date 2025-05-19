import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/screens/organizer/vendor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_app/blocs/auth_bloc/auth_bloc.dart';
import 'package:event_app/blocs/auth_bloc/auth_event.dart';
import 'package:event_app/models/user_model.dart';
import '../auth/signup_screen.dart';
import '../role_selection/role_selection_screen.dart';
import 'organizer_booking_screen.dart';
import 'search_organizer_page.dart';
import '../../widgets/curved_bottom_nav.dart';
import '../../services/quote_service.dart';
import '../../models/quote_model.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  final CustomUser user;

  const OrganizerDashboardScreen({super.key, required this.user});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  Quote? quote;
  bool isLoading = true;

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    loadQuote();
  }

  Future<void> loadQuote() async {
    final fetchedQuote = await fetchQuote();
    setState(() {
      quote = fetchedQuote;
      isLoading = false;
    });
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
    OrganizerBookingScreen(organizerId: widget.user.uid), // 0
    _buildDashboardContent(),                             // 1
    SearchOrganizerPage(),                                // 2
  ];

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${widget.user.displayName ?? "Organizer"}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          const Text(
            '“Connecting dreams with reality — one event at a time.”',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.deepPurpleAccent,
            ),
            textAlign: TextAlign.center,
          ),

          // Text(
          //   '“${quote?.content ?? ''}”',
          //   style: const TextStyle(
          //     fontSize: 16,
          //     fontStyle: FontStyle.italic,
          //     color: Colors.deepPurpleAccent,
          //   ),
          //   textAlign: TextAlign.center,
          // ),

          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/splash2.PNG',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: const [
                  Text(
                    'Your Event Command Center',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Easily search for vendors, manage your bookings, and plan your events effortlessly.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            'Explore All Vendor Listings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          //Firestore Stream of Vendors
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vendors').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No vendor posts available.');
              }

              final vendors = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vendors.length,
            //    separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = vendors[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final imageUrl = data['image_url'];

                  return ListTile(
                    leading: imageUrl != null
                        ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.image_not_supported),
                    title: Text(
                      (data['business_name']?.toString().isNotEmpty ?? false)
                          ? data['business_name']
                          : (data['venue_name']?.toString().isNotEmpty ?? false)
                          ? data['venue_name']
                          : 'Unnamed',
                      style: const TextStyle(
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
                            postId: doc.id,
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
        title: const Text('Organizer Hub',  style: TextStyle(color: Colors.white,
          fontWeight: FontWeight.w500,)),
        centerTitle: true,
        backgroundColor:Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
