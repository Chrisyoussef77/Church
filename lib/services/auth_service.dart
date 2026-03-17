import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // تسجيل الدخول
  Future<String?> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null; // نجاح
    } catch (e) {
      return e.toString();
    }
  }

  // تسجيل حساب جديد
  Future<String?> signUp(String email, String password) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // نسيت الباسورد
Future<String?> resetPassword(String email) async {
  try {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'http://localhost:8080',
    );
    return null;
  } catch (e) {
    return e.toString();
  }
}

  // تسجيل الخروج
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}