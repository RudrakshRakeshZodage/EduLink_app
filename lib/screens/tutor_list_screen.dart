import 'package:flutter/material.dart';

class TutorListScreen extends StatelessWidget {
  const TutorListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Tutors')),
      body: const Center(child: Text('Tutor List - Use Search Screen')),
    );
  }
}
