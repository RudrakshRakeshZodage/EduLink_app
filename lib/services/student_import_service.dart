import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

class StudentImportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pick and parse CSV file
  Future<List<Map<String, dynamic>>?> pickAndParseCSV() async {
    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        print('No file selected');
        return null;
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        print('Could not read file');
        return null;
      }

      // Parse CSV
      final csvString = utf8.decode(bytes);
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty) {
        print('CSV file is empty');
        return null;
      }

      // First row is headers
      final headers = csvData[0].map((e) => e.toString().toLowerCase().trim()).toList();
      final students = <Map<String, dynamic>>[];

      // Parse each row
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.isEmpty) continue;

        final studentData = <String, dynamic>{};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          studentData[headers[j]] = row[j];
        }

        // Convert to student model format
        students.add({
          'name': studentData['name']?.toString() ?? 'Unknown',
          'email': studentData['email']?.toString() ?? '',
          'rollNumber': studentData['roll_number']?.toString() ?? studentData['rollnumber']?.toString() ?? '',
          'class': studentData['class']?.toString() ?? '',
          'attendance': _parseDouble(studentData['attendance']) ?? 75.0,
          'phone': studentData['phone']?.toString() ?? '',
          'parentContact': studentData['parent_contact']?.toString() ?? studentData['parent']?.toString() ?? '',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('✓ Parsed ${students.length} students from CSV');
      return students;
    } catch (e) {
      print('Error parsing CSV: $e');
      return null;
    }
  }

  /// Save students to Firestore
  Future<int> saveStudentsToFirestore(List<Map<String, dynamic>> students) async {
    try {
      final batch = _firestore.batch();
      int count = 0;

      for (var student in students) {
        final docRef = _firestore.collection('students').doc();
        batch.set(docRef, student);
        count++;
      }

      await batch.commit();
      print('✓ Saved $count students to Firestore');
      return count;
    } catch (e) {
      print('Error saving students: $e');
      return 0;
    }
  }

  /// Update student
  Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('students').doc(studentId).update(data);
      print('✓ Updated student $studentId');
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  /// Delete student
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
      print('✓ Deleted student $studentId');
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  /// Get all students
  Stream<List<Map<String, dynamic>>> getStudentsStream() {
    return _firestore
        .collection('students')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Generate sample CSV content
  String generateSampleCSV() {
    final headers = ['name', 'email', 'roll_number', 'class', 'attendance', 'phone', 'parent_contact'];
    final sampleData = [
      ['Rahul Sharma', 'rahul.sharma@student.edu', 'CS2024001', 'Class 12-A', '92.5', '9876543210', '9876543211'],
      ['Priya Patel', 'priya.patel@student.edu', 'CS2024002', 'Class 12-A', '88.0', '9876543212', '9876543213'],
      ['Arjun Kumar', 'arjun.kumar@student.edu', 'CS2024003', 'Class 12-B', '95.5', '9876543214', '9876543215'],
      ['Sneha Reddy', 'sneha.reddy@student.edu', 'CS2024004', 'Class 12-B', '90.0', '9876543216', '9876543217'],
      ['Vikram Singh', 'vikram.singh@student.edu', 'CS2024005', 'Class 11-A', '85.5', '9876543218', '9876543219'],
    ];

    const converter = ListToCsvConverter();
    return converter.convert([headers, ...sampleData]);
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    try {
      return double.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}
