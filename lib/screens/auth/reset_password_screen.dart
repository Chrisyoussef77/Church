import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> 
{
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
void initState() {
  super.initState();
  
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      setState(() {});
    }
  });
}

  Future<void> _updatePassword() async {
    if (_passwordController.text.isEmpty || _confirmController.text.isEmpty) {
      _showMessage('Please fill all fields', Colors.red);
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showMessage('Passwords do not match', Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showMessage('Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      _showMessage('Password updated successfully ✅', Colors.green);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      _showMessage(e.toString(), Colors.red);
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مدرسه الطغمات السمائيه للشمامسه',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        'مدرسه تهدف لتعليم الالحان والطقوس الكنسيه',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B6914),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  ),
                  Column(
                    children: [
                      Image.asset('assets/logo.jpeg', width: 55, height: 55),
                      const Text(
                        'كنيسه العذراء مريم والسمائيين',
                        style: TextStyle(fontSize: 9, color: Color(0xFF5C3D2E)),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 60),

              const Icon(Icons.lock_reset, size: 80, color: Color(0xFF5C3D2E)),

              const SizedBox(height: 20),

              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your new password',
                style: TextStyle(fontSize: 14, color: Color(0xFF8B6914)),
              ),

              const SizedBox(height: 40),

              // New Password
              TextField(
                controller: _passwordController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: Color(0xFF5C3D2E)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF5C3D2E),
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: Color(0xFF5C3D2E)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF5C3D2E),
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}