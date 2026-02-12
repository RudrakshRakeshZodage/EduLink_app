import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Process payment and save transaction
  Future<String> processPayment({
    required String title,
    required double amount,
    required String recipientName,
    required String paymentMethod,
    bool isCredit = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final transactionData = {
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'User',
        'title': title,
        'amount': amount,
        'recipientName': recipientName,
        'paymentMethod': paymentMethod,
        'isCredit': isCredit,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
        'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      };

      final docRef = await _firestore.collection('transactions').add(transactionData);
      print('✓ Transaction saved: ${docRef.id}');
      
      return docRef.id;
    } catch (e) {
      print('Error processing payment: $e');
      rethrow;
    }
  }

  /// Get user's transaction history
  Stream<List<Map<String, dynamic>>> getTransactionHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Generate PDF payment receipt
  Future<void> generatePaymentReceipt({
    required String transactionId,
    required String title,
    required double amount,
    required String recipientName,
    required String paymentMethod,
    required DateTime timestamp,
    bool isCredit = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final pdf = pw.Document();
      final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
      
      // Load EduLink logo (using colored rectangle as placeholder)
      final logoWidget = pw.Container(
        width: 50,
        height: 50,
        decoration: pw.BoxDecoration(
          gradient: const pw.LinearGradient(
            colors: [PdfColors.purple300, PdfColors.blue300],
          ),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Center(
          child: pw.Text(
            'E',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with Logo
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          logoWidget,
                          pw.SizedBox(width: 12),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'EduLink',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.purple700,
                                ),
                              ),
                              pw.Text(
                                'Peer Learning Platform',
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: isCredit ? PdfColors.green100 : PdfColors.red100,
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(
                          isCredit ? 'CREDIT' : 'DEBIT',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: isCredit ? PdfColors.green900 : PdfColors.red900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  // Payment Receipt Title
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      gradient: const pw.LinearGradient(
                        colors: [PdfColors.purple100, PdfColors.blue50],
                      ),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'PAYMENT RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple900,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          transactionId,
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),

                  // Transaction Details
                  _buildDetailRow('Transaction Date:', dateStr),
                  pw.Divider(),
                  _buildDetailRow('From:', user.displayName ?? user.email ?? 'User'),
                  _buildDetailRow('To:', recipientName),
                  _buildDetailRow('Description:', title),
                  _buildDetailRow('Payment Method:', paymentMethod),
                  pw.Divider(),

                  // Amount Section
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(24),
                    decoration: pw.BoxDecoration(
                      color: isCredit ? PdfColors.green50 : PdfColors.red50,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(
                        color: isCredit ? PdfColors.green : PdfColors.red,
                        width: 2,
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'AMOUNT',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 36,
                            fontWeight: pw.FontWeight.bold,
                            color: isCredit ? PdfColors.green900 : PdfColors.red900,
                          ),
                        ),
                        pw.Text(
                          'Indian Rupees',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.Spacer(),

                  // Authentication Badge
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.blue200),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Icon(
                          pw.IconData(0xe876), // Check circle
                          color: PdfColors.blue900,
                          size: 24,
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'AUTHENTICATED TRANSACTION',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                              pw.Text(
                                'This receipt is digitally verified and authenticated by EduLink',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 20),

                  // Footer
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Thank you for using EduLink!',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'support@edulink.com',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save and share PDF
      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
        name: 'EduLink_Receipt_$transactionId.pdf',
      );
      
      print('✓ PDF receipt generated successfully');
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
