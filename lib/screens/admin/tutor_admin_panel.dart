import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class TutorAdminPanel extends StatefulWidget {
  const TutorAdminPanel({super.key});

  @override
  State<TutorAdminPanel> createState() => _TutorAdminPanelState();
}

class _TutorAdminPanelState extends State<TutorAdminPanel> {
  String activeTab = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
             decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF2DD4BF)]),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => appState.setScreen('profile'),
                    ),
                    const Text('Tutor Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab('dashboard', 'Dashboard'),
                      _buildTab('services', 'Services'),
                      _buildTab('requests', 'Requests'),
                      _buildTab('earnings', 'Earnings'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildContent(appState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String key, String label) {
    final isActive = activeTab == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (val) => setState(() => activeTab = key),
        selectedColor: Colors.white,
        backgroundColor: Colors.white24,
        labelStyle: TextStyle(
          color: isActive ? Colors.purple : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
      ),
    );
  }

  Widget _buildContent(AppState appState) {
    switch (activeTab) {
      case 'dashboard':
        return Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Earnings', '₹12,450', Icons.attach_money, Colors.green[100]!, Colors.green),
                _buildStatCard('Active Svc', '8', Icons.book, Colors.blue[100]!, Colors.blue),
                _buildStatCard('Students', '24', Icons.people, Colors.purple[100]!, Colors.purple),
                _buildStatCard('Rating', '4.8', Icons.star, Colors.yellow[100]!, Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   const SizedBox(height: 12),
                   _buildActivityItem(Icons.attach_money, Colors.green, 'Payment received', '₹300 from Tanisha T.', '2h ago'),
                   const Divider(height: 24),
                   _buildActivityItem(Icons.message, Colors.blue, 'New message', 'From Rohit K. about Java help', '5h ago'),
                ],
              ),
            ),
          ],
        );
      case 'services':
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => appState.setScreen('upload'),
              child: const Text('Add New Service'),
            ),
            const SizedBox(height: 12),
            _buildServiceCard('Math Assignment Help', '₹250/hr', 'Active'),
            _buildServiceCard('Python Notes', '₹180', 'Active'),
          ],
        );
      case 'requests':
        return Column(
          children: [
            _buildRequestCard('Tanisha T.', 'Math', 'Integration Help', 'High'),
            _buildRequestCard('Rohit K.', 'Programming', 'Java OOP', 'Medium'),
          ],
        );
      case 'earnings':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.green, Colors.blue]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text('Total Earnings', style: TextStyle(color: Colors.white70)),
              Text('₹12,450', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           CircleAvatar(backgroundColor: bg, radius: 14, child: Icon(icon, color: color, size: 16)),
           const Spacer(),
           Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String price, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          ),
           Chip(label: Text(status), backgroundColor: Colors.green[100], labelStyle: TextStyle(color: Colors.green[800], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(String student, String subject, String topic, String urgency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(student, style: const TextStyle(fontWeight: FontWeight.bold)),
               Chip(label: Text(urgency), backgroundColor: Colors.red[100], labelStyle: TextStyle(color: Colors.red[800], fontSize: 10)),
            ],
          ),
          Text(topic),
          Text(subject, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
               Provider.of<AppState>(context, listen: false).setScreen('chat');
            }, 
            child: const Text('Accept & Chat')
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, Color color, String title, String subtitle, String time) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 18,
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
