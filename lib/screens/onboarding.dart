import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [

              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Preview with Circle Background
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF515FDD).withOpacity(0.2),
                          ),
                        ),
                       Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Image.asset(
                          'assets/app_preview.png', // Path from the project root
                          fit: BoxFit.contain,
                         ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Stock trading suit',
                      style: TextStyle(
                        color: Color(0xFF0D0D12),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    const Text(
                      'Streamline your investment decisions\nwith expert guidance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF666D80),
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Progress Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF515FDD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECEFF3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECEFF3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  children: [
                    // Sign In Button
                    OutlinedButton(
                      onPressed: () {
                        // Navigate to the sign-in page
                        Navigator.pushNamed(context, '/signin');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(
                          color: Color(0xFF515FDD),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Color(0xFF515FDD),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the signup page
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF515FDD),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

