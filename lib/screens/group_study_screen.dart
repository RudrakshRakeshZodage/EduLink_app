import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class GroupStudyScreen extends StatelessWidget {
  const GroupStudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final groups = [
      {'title': 'JEE Physics Masters', 'members': 145, 'active': 12, 'topic': 'Rotational Motion'},
      {'title': 'Python Learners', 'members': 89, 'active': 8, 'topic': 'Django Framework'},
      {'title': 'UPSC CSE 2025', 'members': 230, 'active': 45, 'topic': 'Current Affairs'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setScreen('home'),
        ),
        title: const Text('Group Study'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: Icon(Icons.group, color: Colors.purple[700]),
              ),
              title: Text(group['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${group['members']} members • ${group['active']} online\nTopic: ${group['topic']}'),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () => appState.setScreen('chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Join'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Create Group'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFC084FC),
      ),
    );
  }
}
