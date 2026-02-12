import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String postType = 'request';
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String subject = '';
  String description = '';
  String budget = '';
  String tags = '';

  final subjects = ['Mathematics', 'Physics', 'Chemistry', 'Computer Science', 'English'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => appState.setScreen('home'),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Share Knowledge',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _fillDummyData,
                        child: const Text('Fill Demo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildTypeButton('request', 'Need Guidance')),
                        Expanded(child: _buildTypeButton('offer', 'Peer Tutoring')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(postType == 'request' ? 'What guidance do you need?' : 'What can you teach?'),
                      TextFormField(
                        initialValue: title,
                        onChanged: (val) => title = val,
                        decoration: _inputDecoration('e.g., Concept clarity in Calculus'),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Subject Area'),
                      DropdownButtonFormField<String>(
                        initialValue: subject.isNotEmpty ? subject : null,
                        items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => subject = val ?? ''),
                        decoration: _inputDecoration('Select Subject'),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Details'),
                      TextFormField(
                        initialValue: description,
                        onChanged: (val) => description = val,
                        maxLines: 4,
                        decoration: _inputDecoration('Describe what you need...'),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel(postType == 'request' ? 'Budget Range' : 'Tutoring Fee'),
                      TextFormField(
                        initialValue: budget,
                        onChanged: (val) => budget = val,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Amount in ₹', icon: Icons.currency_rupee),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Tags'),
                      TextFormField(
                        initialValue: tags,
                        onChanged: (val) => tags = val,
                        decoration: _inputDecoration('e.g., doubt, notes'),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // In real app, submit data here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post created successfully! 🎉')),
                            );
                            appState.setScreen('home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: postType == 'request' ? const Color(0xFFC084FC) : const Color(0xFF2DD4BF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            postType == 'request' ? 'Request Guidance' : 'Start Peer Tutoring',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label) {
    final isSelected = postType == type;
    final color = type == 'request' ? Colors.purple : Colors.teal;

    return GestureDetector(
      onTap: () => setState(() => postType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? color : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC084FC))),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  void _fillDummyData() {
    setState(() {
      title = 'Need help with Calculus Integration';
      subject = 'Mathematics';
      description = 'Struggling with integration by parts. Exam next week!';
      budget = '300';
      tags = 'calculus, integration, urgent';
    });
  }
}
