import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_detail_screen.dart';

class AdminStudentsScreen extends StatefulWidget {
  final String classId;
  const AdminStudentsScreen({super.key, required this.classId});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String? _expandedStudentId;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await supabase
        .from('profiles')
        .select()
        .eq('class_id', widget.classId)
        .eq('role', 'user')
        .order('full_name');

    setState(() {
      _students = List<Map<String, dynamic>>.from(students);
      _isLoading = false;
    });
  }

  Future<void> _addAttendance(String studentId, String type) async {
    await supabase.from('attendance').insert({
      'student_id': studentId,
      'admin_id': supabase.auth.currentUser!.id,
      'type': type,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type recorded ✅'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addNote(String studentId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await supabase.from('notes').insert({
                  'student_id': studentId,
                  'admin_id': supabase.auth.currentUser!.id,
                  'content': controller.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note added ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E)),
            child:
                const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addVote(String studentId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter grade...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final grade = double.tryParse(controller.text);
              if (grade != null) {
                await supabase.from('votes').insert({
                  'student_id': studentId,
                  'admin_id': supabase.auth.currentUser!.id,
                  'grade': grade,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grade added ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E)),
            child:
                const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        title: const Text('Students',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C3D2E)))
          : _students.isEmpty
              ? const Center(
                  child: Text('No students in your class yet',
                      style: TextStyle(color: Color(0xFF8B6914))))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final isExpanded =
                        _expandedStudentId == student['id'];

                    return Column(
                      children: [
                        // Student Bar
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedStudentId =
                                  isExpanded ? null : student['id'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // صورة الطالب
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentDetailScreen(
                                        student: student,
                                      ),
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        const Color(0xFF5C3D2E),
                                    backgroundImage:
                                        student['avatar_url'] != null
                                            ? NetworkImage(
                                                student['avatar_url'])
                                            : null,
                                    child: student['avatar_url'] == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    student['full_name'] ?? 'Student',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C1810),
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF5C3D2E),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action Circles
                        if (isExpanded)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE0D4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionCircle(
                                  letter: 'R',
                                  color: Colors.orange,
                                  onTap: () => _addAttendance(
                                      student['id'], 'ritardness'),
                                ),
                                _buildActionCircle(
                                  letter: 'A',
                                  color: Colors.red,
                                  onTap: () => _addAttendance(
                                      student['id'], 'absence'),
                                ),
                                _buildActionCircle(
                                  letter: 'N',
                                  color: Colors.blue,
                                  onTap: () => _addNote(student['id']),
                                ),
                                _buildActionCircle(
                                  letter: 'V',
                                  color: Colors.green,
                                  onTap: () => _addVote(student['id']),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildActionCircle({
    required String letter,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}