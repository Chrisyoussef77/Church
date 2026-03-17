import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _fullNameController = TextEditingController();
  final _classCodeController = TextEditingController();
  final supabase = Supabase.instance.client;
  DateTime? _selectedDate;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;

  final List<String> _adminEmails = [
    'maximousyousef2@gmail.com',
    'amerh33333@gmail.com',
    'shenoudaelkesmakrawy@gmail.com',
    'beshoyadeleid@gmail.com',
    'minatech83@gmail.com',
    'marynazmy165@gmail.com',
    'gergesmariam775@gmail.com',
    'krst123remon@gmail.com',
    'marinamaher690@gmail.com',
  ];

  final String _superAdminEmail = 'kirolossalib1@gmail.com';

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5C3D2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    final bytes = await picked.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = picked.name;
    });
  }
}

  Future<void> _saveProfile() async 
  {
    if (_fullNameController.text.isEmpty || _selectedDate == null) {
      _showMessage('Please fill all required fields', Colors.red);
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final email = user.email!.toLowerCase();
    String role = 'user';

    if (email == _superAdminEmail) {
      role = 'superadmin';
    } else if (_adminEmails.contains(email)) {
      role = 'admin';
    }

    // لو مش superadmin لازم يدخل كود الفصل
    if (role == 'user' && _classCodeController.text.isEmpty) {
      _showMessage('Please enter your class code', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? avatarUrl;

          // رفع الصورة لو اختار
    // امسح الكود القديم بتاع الصورة وحط ده بدله
    if (_selectedImageBytes != null) {
      final fileName = '${user.id}_avatar.jpg';
      await supabase.storage.from('avatars').uploadBinary(
        fileName,
        _selectedImageBytes!,
        fileOptions: const FileOptions(upsert: true),
      );
      avatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
    }

          // جيب الـ class id لو user
      // بعد ما بيحدد الـ role
      if (role == 'admin' && _classCodeController.text.isEmpty) 
      {
        _showMessage('Please enter your class code', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

    // وفي جزء جيب الـ class id، عدّله عشان يشمل الـ admin
    String? classId;
    if (role == 'user') {
    final classData = await supabase
      .from('classes')
      .select('id')
      .eq('code', _classCodeController.text.trim().toUpperCase())
      .maybeSingle();

   if (classData == null) 
    {
      _showMessage('Invalid class code', Colors.red);
      setState(() => _isLoading = false);
      return;
    }
    classId = classData['id'];
    }

    if (role == 'admin') {
  final classIds = _classCodeController.text
      .split(',')
      .map((e) => e.trim().toUpperCase())
      .where((e) => e.isNotEmpty)
      .toList();

  await supabase.from('profiles').upsert({
    'id': user.id,
    'email': user.email,
    'full_name': _fullNameController.text.trim(),
    'birth_date': _selectedDate!.toIso8601String(),
    'role': role,
    'avatar_url': avatarUrl,
    'class_ids': classIds,
  });
} else {
      // حفظ البيانات في profiles
      await supabase.from('profiles').upsert(
      {
        'id': user.id,
        'email': user.email,
        'full_name': _fullNameController.text.trim(),
        'birth_date': _selectedDate!.toIso8601String(),
        'role': role,
        'avatar_url': avatarUrl,
        'class_id': classId,
      });
    }

      if (mounted) 
      {
        _navigateByRole(role);
      }
    } 
    catch (e) 
    {
      _showMessage(e.toString(), Colors.red); // ← غير دي مؤقتاً
    }

    setState(() => _isLoading = false);
  }

    void _navigateByRole(String role) 
    {
      switch (role) 
      {
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
                  child: Column
                  (
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
                          fontSize: 16,
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

              const SizedBox(height: 30),

              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),

              const SizedBox(height: 30),

              // صورة البروفايل
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF5C3D2E),
                    backgroundImage: _selectedImageBytes != null
                        ? MemoryImage(_selectedImageBytes!)
                        : null,
                    child: _selectedImageBytes == null
                        ? const Icon(Icons.person, size: 55, color: Colors.white)
                        : null,
                  ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B6914),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Optional',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B6914)),
              ),

              const SizedBox(height: 24),

              // الاسم الثلاثي
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Color(0xFF5C3D2E)),
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

              // تاريخ الميلاد
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF5C3D2E)),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Birth Date *'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? Colors.grey
                              : const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // كود الفصل (مش بيظهر للـ superadmin)
FutureBuilder(
  future: _checkIsSuperAdmin(),
  builder: (context, snapshot) {
    if (snapshot.data == true) return const SizedBox();
    return TextField(
      controller: _classCodeController,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Class Code *',
        hintText: 'e.g. CLS3B or CLS1A, CLS2B',
        prefixIcon: const Icon(Icons.class_outlined,
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
              color: Color(0xFF5C3D2E), width: 2),
        ),
      ),
    );
  },
),

              const SizedBox(height: 30),

              // زرار الحفظ
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continue',
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

  Future<bool> _checkIsSuperAdmin() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    return user.email?.toLowerCase() == _superAdminEmail;
  }
}