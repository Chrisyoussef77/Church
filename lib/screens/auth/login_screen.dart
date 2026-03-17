import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fragment = Uri.base.fragment;
      print('LOGIN SCREEN FRAGMENT: $fragment');

      if (fragment.contains('type=recovery')) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/reset-password');
          return;
        }
      }
    });

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('LOGIN EVENT: ${data.event}');
      if (data.event == AuthChangeEvent.passwordRecovery && mounted) {
        Navigator.pushReplacementNamed(context, '/reset-password');
      }
    });
  }

  Future<void> _checkForResetCode() async {
    final uri = Uri.base;

    final fragment = uri.fragment;
    if (fragment.contains('type=recovery')) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/reset-password');
        return;
      }
    }

    final code = uri.queryParameters['code'];
    if (code != null) {
      try {
        await Supabase.instance.client.auth.exchangeCodeForSession(code);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/reset-password');
        }
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response.user != null) {
        if (mounted) {
          final profile = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (!mounted) return;

          if (profile == null) {
            Navigator.pushReplacementNamed(context, '/setup');
          } else {
            final role = profile['role'];
            switch (role) {
              case 'superadmin':
                Navigator.pushReplacementNamed(context, '/superadmin');
                break;
              case 'admin':
                Navigator.pushReplacementNamed(context, '/admin');
                break;
              default:
                Navigator.pushReplacementNamed(context, '/user');
            }
          }
        }
      } else {
        _showError('Invalid email or password');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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

              // ============ HEADER WITH logo2.jpeg ADDED ============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT SIDE - Arabic text + logo2.jpeg
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مدرسه الطغمات السمائيه للشمامسه',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3D2E),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const Text(
                          'مدرسه تهدف لتعليم الالحان والطقوس الكنسيه',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B6914),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        // ============ logo2.jpeg ADDED HERE ============
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/logo2.jpeg',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // RIGHT SIDE - logo.jpeg
                  Column(
                    children: [
                      Image.asset(
                        'assets/logo.jpeg',
                        width: 55,
                        height: 55,
                      ),
                      const Text(
                        'كنيسه العذراء مريم والسمائيين',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5C3D2E),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5C3D2E),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B6914),
                ),
              ),

              const SizedBox(height: 40),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: Color(0xFF5C3D2E)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF5C3D2E),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: Color(0xFF5C3D2E)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF5C3D2E),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF5C3D2E),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF8B6914)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Color(0xFF2C1810)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF5C3D2E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}