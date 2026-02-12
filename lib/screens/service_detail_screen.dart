import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, arguments would be passed here
    final service = {
      'title': 'Mathematics Assignment Help',
      'tutor': 'Kalyani M.',
      'price': '₹250',
      'description': 'Detailed notes and step-by-step solutions for Calculus and Algebra problems.',
      'rating': 4.9,
      'reviews': 24
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service['title'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(child: Text('KM')),
                const SizedBox(width: 8),
                Text(service['tutor'] as String, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Text(service['price'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(service['description'] as String, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const  Spacer(),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () {
                    Provider.of<AppState>(context, listen: false).setScreen('chat');
                 },
                 child: const Text('Chat with Tutor'),
               ),
             )
          ],
        ),
      ),
    );
  }
}
