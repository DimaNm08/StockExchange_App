import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Status Bar Time (Fake)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '9:41',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.signal_cellular_4_bar, size: 16),
                            SizedBox(width: 4),
                            Icon(Icons.battery_full, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance for back button
                      ],
                    ),
                  ),

                  // Profile Info
                  const SizedBox(height: 24),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3E52C1),
                      image: DecorationImage(
                        image: NetworkImage('https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Stockwave___Stock_App_UI_Kit__Community_-Bmmqt7QI4n9CH5kbaTpHvOumUZer5n.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dumitru Nimerenco',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'dumitrunimerenco@gmail.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Invite Friends Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: const Color(0xFFF7FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            color: Color(0xFF3E52C1),
                          ),
                        ),
                        title: const Text(
                          'Invite friends',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Invite your friends and get \$15'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Menu
                  _buildMenuItem(Icons.person_outline, 'Account'),
                  _buildMenuItem(Icons.fingerprint, 'Security'),
                  _buildMenuItem(Icons.credit_card, 'Billing / Payments'),
                  _buildMenuItem(
                    Icons.language,
                    'Language',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'English',
                          style: TextStyle(
                            color: Color(0xFF718096),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Color(0xFF718096)),
                      ],
                    ),
                  ),
                  _buildMenuItem(Icons.settings, 'Settings'),
                  _buildMenuItem(Icons.help_outline, 'FAQ'),
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined),
                    _buildNavItem(Icons.pie_chart_outline),
                    _buildFloatingNavItem(Icons.people),
                    _buildNavItem(Icons.trending_up),
                    _buildNavItem(Icons.person_outline),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF718096)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right, color: Color(0xFF718096)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon) {
    return IconButton(
      icon: Icon(icon),
      color: const Color(0xFF718096),
      onPressed: () {},
    );
  }

  Widget _buildFloatingNavItem(IconData icon) {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF3E52C1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}