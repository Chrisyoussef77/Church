import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLessonsScreen extends StatefulWidget {
  final String classId;
  const AdminLessonsScreen({super.key, required this.classId});

  @override
  State<AdminLessonsScreen> createState() => _AdminLessonsScreenState();
}

class _AdminLessonsScreenState extends State<AdminLessonsScreen> {
  final supabase = Supabase.instance.client;
  final _contentController = TextEditingController();
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await supabase
        .from('lessons')
        .select()
        .eq('class_id', widget.classId)
        .order('lesson_date', ascending: false);

    setState(() {
      _lessons = List<Map<String, dynamic>>.from(lessons);
      _isLoading = false;
    });
  }

  Future<void> _addLesson() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isSaving = true);

    await supabase.from('lessons').insert({
      'class_id': widget.classId,
      'admin_id': supabase.auth.currentUser!.id,
      'content': _contentController.text.trim(),
      'lesson_date': DateTime.now().toIso8601String(),
    });

    _contentController.clear();
    await _loadLessons();

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lesson added ✅'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        title: const Text('Lessons',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C3D2E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Add Lesson Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Lesson",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1810),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Write lesson content here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF5C3D2E)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF5C3D2E), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _addLesson,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C3D2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Add Lesson',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Previous Lessons
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Previous Lessons',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _lessons.isEmpty
                      ? const Text('No lessons yet',
                          style: TextStyle(color: Color(0xFF8B6914)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = _lessons[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.menu_book,
                                          color: Color(0xFF5C3D2E)),
                                      const SizedBox(width: 8),
                                      Text(
                                        lesson['lesson_date']
                                            .toString()
                                            .split('T')[0],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5C3D2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    lesson['content'] ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF2C1810),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}