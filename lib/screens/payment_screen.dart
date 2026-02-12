import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(bool isCredit) async {
    if (_amountController.text.isEmpty || 
        _recipientController.text.isEmpty || 
        _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      
      // Process payment
      final transactionId = await _paymentService.processPayment(
        title: _titleController.text,
        amount: amount,
        recipientName: _recipientController.text,
        paymentMethod: _selectedMethod,
        isCredit: isCredit,
      );

      // Generate PDF receipt
      await _paymentService.generatePaymentReceipt(
        transactionId: transactionId,
        title: _titleController.text,
        amount: amount,
        recipientName: _recipientController.text,
        paymentMethod: _selectedMethod,
        timestamp: DateTime.now(),
        isCredit: isCredit,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Payment ${isCredit ? "received" : "sent"} successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _amountController.clear();
        _recipientController.clear();
        _titleController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF60A5FA)]),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => appState.setScreen('profile'),
                    ),
                    Text('EduWallet', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Balance', style: GoogleFonts.inter(color: Colors.white70)),
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream: user != null ? _paymentService.getTransactionHistory(user.uid) : const Stream.empty(),
                            builder: (context, snapshot) {
                              double balance = 1250.0;
                              if (snapshot.hasData) {
                                for (var txn in snapshot.data!) {
                                  final amount = (txn['amount'] ?? 0).toDouble();
                                  final isCredit = txn['isCredit'] ?? false;
                                  balance += isCredit ? amount : -amount;
                                }
                              }
                              return Text(
                                '₹${balance.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                      )
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Payment Form
                Text('Make Payment', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Mathematics Tutoring',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: 'Recipient Name',
                    hintText: 'e.g., Arjun K.',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    hintText: '0.00',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text('Payment Method', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['UPI', 'Card', 'Wallet'].map((method) {
                    return ChoiceChip(
                      label: Text(method),
                      selected: _selectedMethod == method,
                      onSelected: (selected) {
                        setState(() => _selectedMethod = method);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _processPayment(false),
                        icon: _isProcessing 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send),
                        label: const Text('Send Money'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _processPayment(true),
                        icon: _isProcessing 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.add),
                        label: const Text('Receive Money'),
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
                
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                // Transaction History
                Text('Recent Transactions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                if (user != null)
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _paymentService.getTransactionHistory(user.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final transactions = snapshot.data!;
                      if (transactions.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No transactions yet', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        children: transactions.map((txn) {
                          final title = txn['title'] ?? 'Payment';
                          final recipient = txn['recipientName'] ?? 'Unknown';
                          final amount = (txn['amount'] ?? 0).toDouble();
                          final isCredit = txn['isCredit'] ?? false;
                          
                          return _buildTransaction(title, recipient, amount.toStringAsFixed(2), isCredit)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0);
                        }).toList(),
                      );
                    },
                  )
                else
                  const Center(child: Text('Please login to view transactions')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransaction(String title, String person, String amount, bool isCredit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                Text(person, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? "+" : "-"}₹$amount',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
