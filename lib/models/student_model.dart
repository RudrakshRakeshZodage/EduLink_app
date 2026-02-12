class StudentModel {
  final String name;
  final double attendancePercentage;
  final List<int> testScores;
  final bool isAtRisk;
  final String parentContact;
  bool isPresentToday; // For local state in the UI

  final String? id; // Firestore Doc ID

  StudentModel({
    this.id,
    required this.name,
    required this.attendancePercentage,
    required this.testScores,
    required this.isAtRisk,
    required this.parentContact,
    this.isPresentToday = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'attendancePercentage': attendancePercentage,
      'testScores': testScores,
      'isAtRisk': isAtRisk,
      'parentContact': parentContact,
      'isPresentToday': isPresentToday,
    };
  }

  // Create from Firestore Document
  factory StudentModel.fromMap(Map<String, dynamic> map, String docId) {
    return StudentModel(
      id: docId,
      name: map['name'] ?? '',
      attendancePercentage: (map['attendancePercentage'] ?? 0.0).toDouble(),
      testScores: List<int>.from(map['testScores'] ?? []),
      isAtRisk: map['isAtRisk'] ?? false,
      parentContact: map['parentContact'] ?? '',
      isPresentToday: map['isPresentToday'] ?? false,
    );
  }
}

// Mock Data Service
class MockData {
  static List<StudentModel> getStudents() {
    return [
      StudentModel(
        name: "Arundhati Roy",
        attendancePercentage: 92.0,
        testScores: [85, 88, 90, 87, 89],
        isAtRisk: false,
        parentContact: "Mrs. Roy",
      ),
      StudentModel(
        name: "Rohan Das",
        attendancePercentage: 65.0,
        testScores: [55, 60, 58, 62, 59],
        isAtRisk: true,
        parentContact: "Mr. Das",
      ),
      StudentModel(
        name: "Kabir Singh",
        attendancePercentage: 78.0,
        testScores: [70, 75, 72, 78, 74],
        isAtRisk: false,
        parentContact: "Mrs. Singh",
      ),
      StudentModel(
        name: "Meera Iyer",
        attendancePercentage: 95.0,
        testScores: [92, 95, 94, 96, 98],
        isAtRisk: false,
        parentContact: "Mr. Iyer",
      ),
      StudentModel(
        name: "Vikram Malhotra",
        attendancePercentage: 45.0,
        testScores: [40, 35, 42, 38, 45],
        isAtRisk: true,
        parentContact: "Mrs. Malhotra",
      ),
    ];
  }
}
