import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  final ApiService apiService = ApiService();

  void _sendOtp() async {
    // For now, just simulate OTP sent
    setState(() {
      _otpSent = true;
    });
  }

  void _login() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    bool success = await apiService.login(phone, otp);
    if (success) {
      // Navigate to dashboard on successful login
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PharmaLocator Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            if (_otpSent)
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _otpSent ? _login : _sendOtp,
              child: Text(_otpSent ? 'Login' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
