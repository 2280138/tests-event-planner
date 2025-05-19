import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc/auth_bloc.dart';
import '../../blocs/auth_bloc/auth_state.dart';
import '../vendor/vendor_dashboard_screen.dart';
import '../organizer/organizer_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  // Method to navigate to the respective dashboard based on selected role
  void _navigateToDashboard(BuildContext context, String role) {
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    if (role == 'vendor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VendorDashboardScreen(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrganizerDashboardScreen(user: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the currently authenticated user
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hides default back button
        title: const Text(
          'Role Selection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Greeting message with user name
              Text(
                'Welcome, ${user.displayName}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Role selection instruction
              const Text(
                'Please select the role you are willing to continue with:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Vendor role selection button
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.storefront, size: 30),
                  label: const Text('Continue as Vendor', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _navigateToDashboard(context, 'vendor'),
                ),
              ),
              const SizedBox(height: 30),

              // Organizer role selection button
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.event, size: 30),
                  label: const Text('Continue as Organizer', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _navigateToDashboard(context, 'organizer'),
                ),
              ),
              const SizedBox(height: 40),

              // Informative footer
              const Text(
                'You can always switch roles from your profile.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
