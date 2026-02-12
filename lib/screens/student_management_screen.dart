import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/student_import_service.dart';
import '../main.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final StudentImportService _importService = StudentImportService();
  List<Map<String, dynamic>> _pendingStudents = [];
  bool _isLoading = false;

  Future<void> _importCSV() async {
    setState(() => _isLoading = true);
    
    final students = await _importService.pickAndParseCSV();
    
    setState(() {
      _isLoading = false;
      if (students != null) {
        _pendingStudents = students;
      }
    });

    if (students != null && students.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${students.length} students. Review and save!')),
      );
    }
  }

  Future<void> _saveAllStudents() async {
    if (_pendingStudents.isEmpty) return;

    setState(() => _isLoading = true);
    
    final count = await _importService.saveStudentsToFirestore(_pendingStudents);
    
    setState(() {
      _isLoading = false;
      _pendingStudents.clear();
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Saved $count students successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _downloadSampleCSV() async {
    // For now, on Desktop/Mobile, we will just show a snackbar or log it
    // because dart:html is not available. 
    // In a production app, use path_provider to save to documents directory.
    
    // final csvContent = _importService.generateSampleCSV();
    
    // Simulating download for now on non-web platforms
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample CSV generation not supported on this platform yet (Web only).')),
      );
    }
  }

  void _editStudent(int index) {
    final student = _pendingStudents[index];
    final nameController = TextEditingController(text: student['name']);
    final emailController = TextEditingController(text: student['email']);
    final rollController = TextEditingController(text: student['rollNumber']);
    final classController = TextEditingController(text: student['class']);
    final attendanceController = TextEditingController(text: student['attendance'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Student', style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: rollController,
                decoration: const InputDecoration(labelText: 'Roll Number'),
              ),
              TextField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              TextField(
                controller: attendanceController,
                decoration: const InputDecoration(labelText: 'Attendance %'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingStudents[index]['name'] = nameController.text;
                _pendingStudents[index]['email'] = emailController.text;
                _pendingStudents[index]['rollNumber'] = rollController.text;
                _pendingStudents[index]['class'] = classController.text;
                _pendingStudents[index]['attendance'] = double.tryParse(attendanceController.text) ?? 75.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(int index) {
    setState(() {
      _pendingStudents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setScreen('home'),
        ),
        title: Text('Student Management', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Sample CSV',
            onPressed: _downloadSampleCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with upload button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _importCSV,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.upload_file),
                        label: const Text('Import CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_pendingStudents.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveAllStudents,
                          icon: const Icon(Icons.save),
                          label: Text('Save ${_pendingStudents.length}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(),

          // Pending students cards
          if (_pendingStudents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Review & Edit Students',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: _pendingStudents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No students loaded', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Upload a CSV file to get started', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _downloadSampleCSV,
                          icon: const Icon(Icons.download),
                          label: const Text('Download Sample CSV'),
                        ),
                      ],
                    ).animate().fadeIn(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _pendingStudents.length,
                    itemBuilder: (context, index) {
                      final student = _pendingStudents[index];
                      return _buildStudentCard(student, index)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: index * 50))
                          .slideX(begin: -0.2, end: 0);
                    },
                  ),
          ),

          // Saved students from Firestore
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Saved Students',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _importService.getStudentsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!;
                if (students.isEmpty) {
                  return Center(
                    child: Text('No students saved yet', style: GoogleFonts.inter(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _buildSavedStudentCard(student);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.purple.shade100,
              child: Text(
                student['name']?.toString().substring(0, 1).toUpperCase() ?? 'S',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['name'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(student['email'] ?? '', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildChip('${student['class']}', Icons.class_, Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip('${student['attendance']}%', Icons.check_circle, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editStudent(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteStudent(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            student['name']?.toString().substring(0, 1).toUpperCase() ?? 'S',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        title: Text(student['name'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(student['email'] ?? '', style: GoogleFonts.inter(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await _importService.deleteStudent(student['id']);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student deleted')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
