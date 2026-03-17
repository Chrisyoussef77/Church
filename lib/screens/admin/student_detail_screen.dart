import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final supabase = Supabase.instance.client;
  int _absenceCount = 0;
  int _ritardnessCount = 0;
  int _notesCount = 0;
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final studentId = widget.student['id'];

    final attendance = await supabase
        .from('attendance')
        .select()
        .eq('student_id', studentId);

    final notes = await supabase
        .from('notes')
        .select()
        .eq('student_id', studentId);

    final grades = await supabase
        .from('votes')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    setState(() {
      _absenceCount = attendance.where((a) => a['type'] == 'absence').length;
      _ritardnessCount = attendance.where((a) => a['type'] == 'ritardness').length;
      _notesCount = notes.length;
      _grades = List<Map<String, dynamic>>.from(grades);
      _isLoading = false;
    });
  }

  Future<void> _deleteLastAttendance(String type) async {
    final records = await supabase
        .from('attendance')
        .select()
        .eq('student_id', widget.student['id'])
        .eq('type', type)
        .order('created_at', ascending: false)
        .limit(1);

    if (records.isEmpty) return;

    await supabase.from('attendance').delete().eq('id', records[0]['id']);
    _loadData();
  }

  Future<void> _deleteLastNote() async {
    final records = await supabase
        .from('notes')
        .select()
        .eq('student_id', widget.student['id'])
        .order('created_at', ascending: false)
        .limit(1);

    if (records.isEmpty) return;

    await supabase.from('notes').delete().eq('id', records[0]['id']);
    _loadData();
  }

  Future<void> _deleteGrade(String gradeId) async {
    await supabase.from('votes').delete().eq('id', gradeId);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        title: Text(widget.student['full_name'] ?? 'Student',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C3D2E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // صورة الطالب وبياناته
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF5C3D2E),
                    backgroundImage: widget.student['avatar_url'] != null
                        ? NetworkImage(widget.student['avatar_url'])
                        : null,
                    child: widget.student['avatar_url'] == null
                        ? const Icon(Icons.person, size: 55, color: Colors.white)
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.student['full_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                  ),

                  Text(
                    widget.student['email'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8B6914)),
                  ),

                  Text(
                    widget.student['birth_date'] != null
                        ? 'Born: ${widget.student['birth_date'].toString().split('T')[0]}'
                        : '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B6914)),
                  ),

                  const SizedBox(height: 24),

                  // Absence, Ritardness, Notes counters
                  Row(
                    children: [
                      _buildStatCard('A', 'Absence', _absenceCount, Colors.red,
                          () => _deleteLastAttendance('absence')),
                      const SizedBox(width: 8),
                      _buildStatCard('R', 'Ritardness', _ritardnessCount, Colors.orange,
                          () => _deleteLastAttendance('ritardness')),
                      const SizedBox(width: 8),
                      _buildStatCard('N', 'Notes', _notesCount, Colors.blue,
                          () => _deleteLastNote()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Grades
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Grades',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _grades.isEmpty
                      ? const Text('No grades yet',
                          style: TextStyle(color: Color(0xFF8B6914)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _grades.length,
                          itemBuilder: (context, index) {
                            final grade = _grades[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Text('V',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Grade: ${grade['grade']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C1810),
                                        ),
                                      ),
                                      Text(
                                        grade['created_at'].toString().split('T')[0],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF8B6914),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // زرار مسح الدرجة
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Grade'),
                                        content: const Text(
                                            'Are you sure you want to delete this grade?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _deleteGrade(grade['id']);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Delete',
                                                style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
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

  Widget _buildStatCard(String letter, String label, int count, Color color,
      VoidCallback onDelete) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Text(letter,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF8B6914))),
            const SizedBox(height: 8),
            // زرار الحذف
            GestureDetector(
              onTap: count > 0
                  ? () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Remove Last $label'),
                          content: Text(
                              'Are you sure you want to remove the last $label?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onDelete();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Remove',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                  : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: count > 0
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.remove_circle_outline,
                  color: count > 0 ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}