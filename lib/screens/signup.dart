import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 24),
                      const Text(
                        'Join StockXA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D0D12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Embark on your investment journey with a single dollar.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666D80),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('Username'),
                      const SizedBox(height: 16),
                      _buildTextField('Email'),
                      const SizedBox(height: 16),
                      _buildTextField('Password', isPassword: true),
                      const SizedBox(height: 24),
                      _buildButton(context, 'Continue', isOutlined: false),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Color(0xFF666D80)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildButton(context, 'Continue with Google', isOutlined: true, isGoogle: true),
                      const SizedBox(height: 16),
                      _buildButton(context, 'Continue with Apple', isOutlined: true, isApple: true),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(color: Color(0xFF666D80)),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: const TextStyle(
                                  color: Color(0xFF3E52C1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFECEFF3)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFECEFF3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFECEFF3)),
        ),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off, color: Color(0xFF666D80))
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, {bool isOutlined = false, bool isGoogle = false, bool isApple = false}) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFECEFF3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGoogle)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.android, size: 20, color: Colors.green),
                    )
                  else if (isApple)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.apple, size: 20),
                    ),
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: () {
                if (text == 'Continue') {
                  Navigator.pushReplacementNamed(context, '/homepage');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E52C1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(text),
            ),
    );
  }
}

