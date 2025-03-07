import 'package:flutter/material.dart';
import '../services/user_service.dart';

class DemoSetupScreen extends StatefulWidget {
  const DemoSetupScreen({Key? key}) : super(key: key);

  @override
  _DemoSetupScreenState createState() => _DemoSetupScreenState();
}

class _DemoSetupScreenState extends State<DemoSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginNameController = TextEditingController();
  final _emailController = TextEditingController();
  double _selectedBalance = 10000.0;
  
  final List<double> _balanceOptions = [1000.0, 5000.0, 10000.0, 50000.0, 100000.0];
  
  @override
  void dispose() {
    _loginNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Setup Demo Account'),
        backgroundColor: const Color(0xFF3E52C1),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Your Demo Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D0D12),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set up your demo account to start practicing with virtual money',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666D80),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Login Name
                TextFormField(
                  controller: _loginNameController,
                  decoration: InputDecoration(
                    labelText: 'Login Name',
                    hintText: 'Enter your login name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a login name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Balance Selection
                const Text(
                  'Select Starting Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D0D12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Balance Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E52C1).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3E52C1).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\$${_selectedBalance.toInt()}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E52C1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Balance Slider
                      Slider(
                        value: _balanceOptions.indexOf(_selectedBalance).toDouble(),
                        min: 0,
                        max: (_balanceOptions.length - 1).toDouble(),
                        divisions: _balanceOptions.length - 1,
                        activeColor: const Color(0xFF3E52C1),
                        inactiveColor: const Color(0xFF3E52C1).withOpacity(0.2),
                        onChanged: (value) {
                          setState(() {
                            _selectedBalance = _balanceOptions[value.toInt()];
                          });
                        },
                      ),
                      
                      // Balance Options
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _balanceOptions.map((balance) {
                            return Text(
                              '\$${balance.toInt()}',
                              style: TextStyle(
                                color: balance == _selectedBalance
                                    ? const Color(0xFF3E52C1)
                                    : const Color(0xFF666D80),
                                fontWeight: balance == _selectedBalance
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _createDemoAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E52C1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Demo Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createDemoAccount() async {
    if (_formKey.currentState!.validate()) {
      await UserService().createDemoUser(
        loginName: _loginNameController.text,
        email: _emailController.text,
        balance: _selectedBalance,
      );
      
      // Navigate to home and clear all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/homepage', 
        (route) => false,
      );
    }
  }
}

