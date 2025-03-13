import 'package:flutter/material.dart';
import '../services/user_service.dart';

class AccountSelectionScreen extends StatelessWidget {
  const AccountSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // This centers children vertically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E52C1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Transform.rotate(
                  angle: 45 * 3.14159 / 180,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Header
              const Text(
                'Choose Account Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D0D12),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you want to use StockXA',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666D80),
                ),
              ),
              const SizedBox(height: 40),
              
              // Options
              _buildOptionCard(
                context,
                title: 'Demo Account',
                description: 'Practice trading with virtual money',
                icon: Icons.account_balance,
                color: const Color(0xFF3E52C1),
                onTap: () {
                  Navigator.pushNamed(context, '/demo_setup');
                },
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                title: 'Continue as Guest',
                description: 'Browse without an account',
                icon: Icons.person_outline,
                color: const Color(0xFF666D80),
                onTap: () async {
                  // Create a guest user and navigate to home
                  await UserService().createGuestUser();
                  Navigator.pushReplacementNamed(context, '/homepage');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 60,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D0D12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF666D80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}