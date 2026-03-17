import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import 'user_status_screen.dart';
import 'user_grades_screen.dart';
import 'user_lessons_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5C3D2E)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // ============ HEADER WITH logo2.jpeg ADDED ============
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // LEFT SIDE - Arabic text + logo2.jpeg
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'مدرسه الطغمات السمائيه للشمامسه',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C3D2E),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const Text(
                              'مدرسه تهدف لتعليم الالحان والطقوس الكنسيه',
                              style: TextStyle(
                                fontSize: 10,
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
                        // RIGHT SIDE - logo.jpeg
                        Column(
                          children: [
                            Image.asset('assets/logo.jpeg',
                                width: 50, height: 50),
                            const Text(
                              'كنيسه العذراء مريم والسمائيين',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF5C3D2E),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // صورة المستخدم
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF5C3D2E),
                      backgroundImage: _profile?['avatar_url'] != null
                          ? NetworkImage(_profile!['avatar_url'])
                          : null,
                      child: _profile?['avatar_url'] == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // اسم المستخدم
                    Text(
                      _profile?['full_name'] ?? 'Student',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // الايميل
                    Text(
                      _profile?['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B6914),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // تاريخ الميلاد
                    Text(
                      _profile?['birth_date'] != null
                          ? 'Born: ${_profile!['birth_date'].toString().split('T')[0]}'
                          : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B6914),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Status Bar
                    _buildMenuBar(
                      icon: Icons.info_outline,
                      label: 'Status',
                      subtitle: 'Absence, Ritardness & Notes',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserStatusScreen(
                            studentId: supabase.auth.currentUser!.id,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grades Bar
                    _buildMenuBar(
                      icon: Icons.grade_outlined,
                      label: 'Grades',
                      subtitle: 'View all your grades',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserGradesScreen(
                            studentId: supabase.auth.currentUser!.id,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lessons Bar
                    _buildMenuBar(
                      icon: Icons.menu_book_outlined,
                      label: 'Lessons',
                      subtitle: 'View class lessons',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserLessonsScreen(
                            classId: _profile?['class_id'] ?? '',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logout
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMenuBar({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C3D2E).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5C3D2E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF5C3D2E), size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1810),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B6914),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF5C3D2E), size: 16),
          ],
        ),
      ),
    );
  }
}