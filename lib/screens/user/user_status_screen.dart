import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStatusScreen extends StatefulWidget {
  final String studentId;
  const UserStatusScreen({super.key, required this.studentId});

  @override
  State<UserStatusScreen> createState() => _UserStatusScreenState();
}

class _UserStatusScreenState extends State<UserStatusScreen> {
  final supabase = Supabase.instance.client;
  int _absenceCount = 0;
  int _ritardnessCount = 0;
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final attendance = await supabase
        .from('attendance')
        .select()
        .eq('student_id', widget.studentId);

    final notes = await supabase
        .from('notes')
        .select()
        .eq('student_id', widget.studentId)
        .order('created_at', ascending: false);

    setState(() {
      _absenceCount = attendance
          .where((a) => a['type'] == 'absence')
          .length;
      _ritardnessCount = attendance
          .where((a) => a['type'] == 'ritardness')
          .length;
      _notes = List<Map<String, dynamic>>.from(notes);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        title: const Text('My Status',
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
                  // Absence & Ritardness
                  Row(
                    children: [
                      _buildStatCard('Absence', _absenceCount, 'A',
                          Colors.red),
                      const SizedBox(width: 16),
                      _buildStatCard('Ritardness', _ritardnessCount, 'R',
                          Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Notes
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _notes.isEmpty
                      ? const Center(
                          child: Text('No notes yet',
                              style: TextStyle(color: Color(0xFF8B6914))))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFF5C3D2E),
                                    child: Text('N',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note['content'] ?? '',
                                          style: const TextStyle(
                                              color: Color(0xFF2C1810)),
                                        ),
                                        Text(
                                          note['created_at']
                                              .toString()
                                              .split('T')[0],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF8B6914),
                                          ),
                                        ),
                                      ],
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

  Widget _buildStatCard(
      String label, int count, String letter, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 28,
              child: Text(
                letter,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label,
                style: const TextStyle(color: Color(0xFF8B6914))),
          ],
        ),
      ),
    );
  }
}