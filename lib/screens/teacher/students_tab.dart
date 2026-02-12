import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../models/student_model.dart' as model; // Prefix to avoid conflict if any

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final List<StudentModel> _students = model.MockData.getStudents();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
         actions: [
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                   Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(student.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (student.attendancePercentage < 75)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Low Attendance: ${student.attendancePercentage.toInt()}%',
                                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Report Button
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Performance Report sent to ${student.parentContact}')),
                          );
                        },
                        icon: const Icon(Icons.assessment_outlined),
                        tooltip: 'Generate Report',
                      ),
                    ],
                  ),
                  const Divider(),
                  // Attendance Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mark Attendance (Today)'),
                      Checkbox(
                        value: student.isPresentToday,
                        onChanged: (bool? value) {
                          setState(() {
                            student.isPresentToday = value ?? false;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
