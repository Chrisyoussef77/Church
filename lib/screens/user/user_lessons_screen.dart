import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLessonsScreen extends StatefulWidget {
  final String classId;
  const UserLessonsScreen({super.key, required this.classId});

  @override
  State<UserLessonsScreen> createState() => _UserLessonsScreenState();
}

class _UserLessonsScreenState extends State<UserLessonsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;

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
          : _lessons.isEmpty
              ? const Center(
                  child: Text('No lessons yet',
                      style: TextStyle(color: Color(0xFF8B6914))))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
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
                          const SizedBox(height: 12),
                          Text(
                            lesson['content'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF2C1810),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}