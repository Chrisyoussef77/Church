import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NavigationService {
  static final supabase = Supabase.instance.client;

  static Future<void> navigateAfterLogin(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // جيب بيانات الـ profile
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (!context.mounted) return;

    // لو معندوش profile بعد → روح لشاشة الإعداد
    if (profile == null) {
      Navigator.pushReplacementNamed(context, '/setup');
      return;
    }

    // روح للشاشة المناسبة حسب الـ role
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