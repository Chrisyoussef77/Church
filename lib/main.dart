import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/setup/profile_setup_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/superadmin/superadmin_home_screen.dart';
import 'screens/auth/reset_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Supabase.initialize
(
  url: 'https://ydarvzlrrwszhtdwoeyj.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkYXJ2emxycndzemh0ZHdvZXlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwNDE4NTcsImV4cCI6MjA4OTYxNzg1N30.rz3rfIrUTEsHEts28p6XgLg4uOdjl8hs99GQrU2OSyY',
  authOptions: const FlutterAuthClientOptions
  (
    authFlowType: AuthFlowType.implicit, // ← ضيف دي
  ),
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
      String getInitialRoute() 
    {
      final fragment = Uri.base.fragment;
      print('FRAGMENT: $fragment');
      if (fragment.contains('type=recovery') || 
      fragment.contains('access_token')) 
      {
        return '/reset-password';
      }
        return '/';
    }
    
    return MaterialApp(
      title: 'Heavenly Ranks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C3D2E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/setup': (context) => const ProfileSetupScreen(),
        '/user': (context) => const UserHomeScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/superadmin': (context) => const SuperAdminHomeScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

// بيشيك لو في يوزر لوجد ان ولا لا
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> 
{
  final supabase = Supabase.instance.client;

@override
void initState() 
{
  super.initState();

  // استمع للـ auth events الأول
  supabase.auth.onAuthStateChange.listen((data) async 
  {
    if (!mounted) return;

    final event = data.event;
    final session = data.session;

    // passwordRecovery الأول
    if (event == AuthChangeEvent.passwordRecovery) {
      Navigator.pushReplacementNamed(context, '/reset-password');
      return;
    }


    if (event == AuthChangeEvent.initialSession) 
    {
    // لو في recovery في الـ URL استنى الـ passwordRecovery event
    if (Uri.base.fragment.contains('type=recovery')) {
      return;
    }

    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile == null) {
        Navigator.pushReplacementNamed(context, '/setup');
        return;
      }

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
  });

  // fallback لو مفيش event جه
  Future.delayed(const Duration(seconds: 5), () {
    if (!mounted) return;
    if (Uri.base.fragment.contains('type=recovery')) return;
    if (supabase.auth.currentSession == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  });
}
      @override
      Widget build(BuildContext context) 
      {
        return const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5C3D2E),
        ),
      ),
    );
  }
}
