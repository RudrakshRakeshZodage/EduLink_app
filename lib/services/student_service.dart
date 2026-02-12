import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final CollectionReference _studentsRef = 
      FirebaseFirestore.instance.collection('students');

  // Stream of Students (Real-time)
  Stream<List<StudentModel>> getStudentsStream() {
    return _studentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a new Student
  Future<void> addStudent(StudentModel student) async {
    await _studentsRef.add(student.toMap());
  }

  // Update Attendance
  Future<void> updateAttendance(String id, bool isPresent) async {
    // This logic mimics a simple "toggle" for the daily view
    // In a real app, you'd likely append to an attendance history collection
    await _studentsRef.doc(id).update({
      'isPresentToday': isPresent,
    });
  }
  
  // Delete Student
  Future<void> deleteStudent(String id) async {
    await _studentsRef.doc(id).delete();
  }
}
