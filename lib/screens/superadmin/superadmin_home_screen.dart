import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import 'superadmin_class_screen.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  final List<String> _classes = [
    '1A', '1B', '1C',
    '2A', '2B', '2C',
    '3A', '3B', '3C',
    '4A', '4B', '4C',
    '5A', '5B', '5C',
  ];

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

  Future<void> _moveStudent() async {
    final emailController = TextEditingController();
    String? selectedClass;
    bool isSearching = false;
    Map<String, dynamic>? foundStudent;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.swap_horiz, color: Color(0xFF5C3D2E)),
              SizedBox(width: 8),
              Text('Move Student',
                  style: TextStyle(
                      color: Color(0xFF2C1810), fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email field
                const Text('Student Email',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C3D2E),
                        fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter student email...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isSearching
                          ? null
                          : () async {
                              setDialogState(() => isSearching = true);
                              foundStudent = null;

                              final result = await supabase
                                  .from('profiles')
                                  .select()
                                  .eq('email', emailController.text.trim())
                                  .eq('role', 'user')
                                  .maybeSingle();

                              setDialogState(() {
                                foundStudent = result;
                                isSearching = false;
                              });

                              if (result == null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No student found with this email'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C3D2E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      child: isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.search,
                              color: Colors.white, size: 20),
                    ),
                  ],
                ),

                // Found student card
                if (foundStudent != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE0D4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF5C3D2E),
                          backgroundImage: foundStudent!['avatar_url'] != null
                              ? NetworkImage(foundStudent!['avatar_url'])
                              : null,
                          child: foundStudent!['avatar_url'] == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foundStudent!['full_name'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C1810)),
                              ),
                              Text(
                                'Current class: ${foundStudent!['class_id'] ?? 'None'}',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF8B6914)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                      ],
                    ),
                  ),
                ],

                // Class selector
                if (foundStudent != null) ...[
                  const SizedBox(height: 16),
                  const Text('Move to Class',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    hint: const Text('Select a class'),
                    items: _classes
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text('Class $c')))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedClass = val),
                  ),
                ],

                // Warning
                if (foundStudent != null && selectedClass != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This will delete all grades, attendance, and notes for this student.',
                            style:
                                TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF8B6914))),
            ),
            if (foundStudent != null && selectedClass != null)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _executeStudentMove(
                      foundStudent!, selectedClass!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3D2E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Move Student',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeStudentMove(
      Map<String, dynamic> student, String targetClassName) async {
    final studentId = student['id'];

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5C3D2E)),
      ),
    );

    try {
      print('========== MOVE STUDENT DEBUG ==========');
      print('Student ID: $studentId');
      print('Student Name: ${student['full_name']}');
      print('Target Class Name: $targetClassName');
      
      final classData = await supabase
          .from('classes')
          .select()
          .eq('name', targetClassName)
          .maybeSingle();

      print('Class Data Found: $classData');

      if (classData == null) {
        print('ERROR: Class not found in database!');
        throw Exception('Class not found: $targetClassName');
      }

      print('Target Class ID: ${classData['id']}');

      print('Deleting old records...');
      
      final votesDelete = await supabase
          .from('votes')
          .delete()
          .eq('student_id', studentId)
          .select();
      print('Deleted votes: ${votesDelete.length} records');

      final attendanceDelete = await supabase
          .from('attendance')
          .delete()
          .eq('student_id', studentId)
          .select();
      print('Deleted attendance: ${attendanceDelete.length} records');

      final notesDelete = await supabase
          .from('notes')
          .delete()
          .eq('student_id', studentId)
          .select();
      print('Deleted notes: ${notesDelete.length} records');

      print('Updating student profile...');
      print('Setting class_id to: ${classData['id']}');
      
      final updateResult = await supabase
          .from('profiles')
          .update({'class_id': classData['id']})
          .eq('id', studentId)
          .select();

      print('Update Result: $updateResult');
      print('========== END DEBUG ==========');

      if (mounted) {
        Navigator.pop(context);
        
        if (updateResult.isEmpty) {
          print('WARNING: Update returned empty - may have failed!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Update may have failed - no rows returned'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${student['full_name']} moved to Class $targetClassName ✅'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('========== ERROR ==========');
      print('Error: $e');
      print('===========================');
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openClass(String className) async {
    final classData = await supabase
        .from('classes')
        .select()
        .eq('name', className)
        .maybeSingle();

    if (!mounted) return;

    if (classData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuperAdminClassScreen(
            classId: classData['id'],
            className: className,
          ),
        ),
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
                    // ============ HEADER WITH IMAGE ADDED ============
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // LEFT SIDE - Arabic text + Image
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
                            // ============ NEW IMAGE ADDED HERE ============
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/logo2.jpeg', // Change this to your image name
                                height: 170,
                                width: 170,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        // RIGHT SIDE - Logo
                        Column(
                          children: [
                            Image.asset('assets/logo.jpeg',
                                width:140, height: 140),
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

                    const SizedBox(height: 24),

                    // SuperAdmin Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1810),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _profile?['full_name'] ?? 'Super Admin',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _profile?['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B6914),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _profile?['birth_date'] != null
                          ? 'Born: ${_profile!['birth_date'].toString().split('T')[0]}'
                          : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B6914),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Move Student Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _moveStudent,
                        icon: const Icon(Icons.swap_horiz, color: Colors.white),
                        label: const Text(
                          'Move Student',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C1810),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Classes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 15 classes
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final className = _classes[index];
                        return GestureDetector(
                          onTap: () => _openClass(className),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5C3D2E)
                                      .withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5C3D2E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      className,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Class $className',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C1810),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Color(0xFF5C3D2E), size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

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
}