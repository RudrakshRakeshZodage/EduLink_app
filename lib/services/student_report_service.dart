import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class StudentReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate comprehensive student performance PDF report
  Future<void> generateStudentReport({
    required String studentId,
    required String studentName,
    required double attendancePercentage,
    required List<int> testScores,
    required String parentContact,
    required String className,
  }) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = DateFormat('MMMM dd, yyyy').format(now);
      final avgScore = testScores.isEmpty ? 0 : testScores.reduce((a, b) => a + b) / testScores.length;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      gradient: const pw.LinearGradient(
                        colors: [PdfColors.purple300, PdfColors.blue300],
                      ),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'STUDENT PERFORMANCE REPORT',
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'EduLink - Peer Learning Platform',
                              style: const pw.TextStyle(fontSize: 12, color: PdfColors.white70),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              dateStr,
                              style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),

                  // Student Information
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'STUDENT INFORMATION',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple,
                          ),
                        ),
                        pw.Divider(color: PdfColors.grey300),
                        pw.SizedBox(height: 8),
                        _buildInfoRow('Name:', studentName),
                        _buildInfoRow('Student ID:', studentId),
                        _buildInfoRow('Class:', className),
                        _buildInfoRow('Parent Contact:', parentContact),
                        _buildInfoRow('Report Date:', dateStr),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Performance Summary
                  pw.Text(
                    'PERFORMANCE SUMMARY',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 12),
                  
                  pw.Row(
                    children: [
                      // Attendance Card
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(16),
                          decoration: pw.BoxDecoration(
                            color: attendancePercentage >= 75 ? PdfColors.green50 : PdfColors.red50,
                            borderRadius: pw.BorderRadius.circular(8),
                            border: pw.Border.all(
                              color: attendancePercentage >= 75 ? PdfColors.green : PdfColors.red,
                            ),
                          ),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                'ATTENDANCE',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                '${attendancePercentage.toStringAsFixed(1)}%',
                                style: pw.TextStyle(
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                  color: attendancePercentage >= 75 ? PdfColors.green900 : PdfColors.red900,
                                ),
                              ),
                              pw.Text(
                                attendancePercentage >= 75 ? 'Excellent' : 'Needs Improvement',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: attendancePercentage >= 75 ? PdfColors.green : PdfColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      
                      // Average Score Card
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(16),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(8),
                            border: pw.Border.all(color: PdfColors.blue),
                          ),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                'AVERAGE SCORE',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                '${avgScore.toStringAsFixed(1)}%',
                                style: pw.TextStyle(
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                              pw.Text(
                                '${testScores.length} Tests Taken',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // Test Scores Table
                  if (testScores.isNotEmpty) ...[
                    pw.Text(
                      'TEST SCORES',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Table(
                        border: pw.TableBorder(
                          horizontalInside: pw.BorderSide(color: PdfColors.grey300),
                        ),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(2),
                          2: const pw.FlexColumnWidth(1),
                        },
                        children: [
                          // Header
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                            children: [
                              _buildTableCell('Test #', isHeader: true),
                              _buildTableCell('Score', isHeader: true),
                              _buildTableCell('Grade', isHeader: true),
                            ],
                          ),
                          // Scores
                          ...List.generate(testScores.length, (index) {
                            final score = testScores[index];
                            final grade = _getGrade(score);
                            return pw.TableRow(
                              children: [
                                _buildTableCell('Test ${index + 1}'),
                                _buildTableCell('$score%'),
                                _buildTableCell(grade),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  
                  pw.Spacer(),

                  // Footer
                  pw.Divider(),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated by EduLink Platform',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Page 1 of 1',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save and open PDF
      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
        name: 'Student_Report_${studentName.replaceAll(' ', '_')}_$dateStr.pdf',
      );
      
      print('✓ PDF generated successfully for $studentName');

      // Also save report metadata to Firestore
      await _firestore.collection('reports').add({
        'studentId': studentId,
        'studentName': studentName,
        'generatedAt': FieldValue.serverTimestamp(),
        'attendancePercentage': attendancePercentage,
        'averageScore': avgScore,
        'testCount': testScores.length,
      });
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  String _getGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}
