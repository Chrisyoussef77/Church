import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import 'admin_students_screen.dart';
import 'admin_lessons_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _classes = [];
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

    if (profile != null) {
      List<String> classIds = [];
      
      if (profile['class_ids'] != null) {
        classIds = List<String>.from(profile['class_ids']);
      } else if (profile['class_id'] != null) {
        classIds = [profile['class_id']];
      }

      List<Map<String, dynamic>> classes = [];
      for (final id in classIds) {
        final cls = await supabase
            .from('classes')
            .select()
            .eq('code', id.trim())
            .maybeSingle();
        if (cls != null) classes.add(cls);
      }

      setState(() {
        _profile = profile;
        _classes = classes;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
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
                child: CircularProgressIndicator(color: Color(0xFF5C3D2E)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C3D2E),
                                ),
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'مدرسه تهدف لتعليم الالحان والطقوس الكنسيه',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF8B6914),
                                ),
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
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
                            Image.asset('assets/logo.jpeg', width: 50, height: 50),
                            const Text(
                              'كنيسه العذراء مريم والسمائيين',
                              style: TextStyle(fontSize: 8, color: Color(0xFF5C3D2E)),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Admin Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C3D2E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _profile?['full_name'] ?? 'Admin',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _profile?['email'] ?? '',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF8B6914)),
                    ),

                    const SizedBox(height: 40),

                    // فصول الأدمن
                    if (_classes.isEmpty)
                      const Text(
                        'No classes assigned',
                        style: TextStyle(color: Color(0xFF8B6914)),
                      )
                    else
                      ..._classes.map((cls) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildClassBar(cls),
                      )),

                    const SizedBox(height: 24),

                    // Logout
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildClassBar(Map<String, dynamic> cls) {
    final className = cls['name'] ?? cls['code'] ?? '';
    final classCode = cls['code'] ?? '';
    final shortName = className.replaceAll('Class ', '');

    return GestureDetector(
      onTap: () => _showClassOptions(cls['id'], className),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF5C3D2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  shortName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              className,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1810),
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF5C3D2E), size: 16),
          ],
        ),
      ),
    );
  }

  void _showClassOptions(String classId, String className) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F0E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              className,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuBar(
              icon: Icons.people_outline,
              label: 'Students',
              subtitle: 'Manage class students',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AdminStudentsScreen(classId: classId),
                ));
              },
            ),
            const SizedBox(height: 16),
            _buildMenuBar(
              icon: Icons.menu_book_outlined,
              label: 'Lessons',
              subtitle: 'Add & manage lessons',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AdminLessonsScreen(classId: classId),
                ));
              },
            ),
            const SizedBox(height: 16),
          ],
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
                Text(label, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C1810),
                )),
                Text(subtitle, style: const TextStyle(
                  fontSize: 12, color: Color(0xFF8B6914),
                )),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF5C3D2E), size: 16),
          ],
        ),
      ),
    );
  }
}