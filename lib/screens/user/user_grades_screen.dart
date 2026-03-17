import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserGradesScreen extends StatefulWidget {
  final String studentId;
  const UserGradesScreen({super.key, required this.studentId});

  @override
  State<UserGradesScreen> createState() => _UserGradesScreenState();
}

class _UserGradesScreenState extends State<UserGradesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final grades = await supabase
        .from('votes')
        .select()
        .eq('student_id', widget.studentId)
        .order('created_at', ascending: false);

    setState(() {
      _grades = List<Map<String, dynamic>>.from(grades);
      _isLoading = false;
    });
  }

  double get _average {
    if (_grades.isEmpty) return 0;
    final total = _grades.fold<double>(
        0, (sum, g) => sum + (g['grade'] as num).toDouble());
    return total / _grades.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        title: const Text('My Grades',
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
                  // Average Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C3D2E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('Average Grade',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        Text(
                          _average.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_grades.length} grades recorded',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _grades.isEmpty
                      ? const Center(
                          child: Text('No grades yet',
                              style: TextStyle(color: Color(0xFF8B6914))))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _grades.length,
                          itemBuilder: (context, index) {
                            final grade = _grades[index];
                            final gradeValue =
                                (grade['grade'] as num).toDouble();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: gradeValue >= 50
                                        ? Colors.green
                                        : Colors.red,
                                    child: Text(
                                      'V',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Grade: $gradeValue',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C1810),
                                        ),
                                      ),
                                      Text(
                                        grade['created_at']
                                            .toString()
                                            .split('T')[0],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF8B6914),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    gradeValue >= 50 ? '✅' : '❌',
                                    style: const TextStyle(fontSize: 20),
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