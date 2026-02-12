import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class StudentAdminPanel extends StatefulWidget {
  const StudentAdminPanel({super.key});

  @override
  State<StudentAdminPanel> createState() => _StudentAdminPanelState();
}

class _StudentAdminPanelState extends State<StudentAdminPanel> {
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
              gradient: LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFFC084FC)]),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => appState.setScreen('profile'),
                    ),
                    const Text('Student Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab('dashboard', 'Dashboard'),
                      _buildTab('requests', 'My Requests'),
                      _buildTab('tutors', 'Find Tutors'),
                      _buildTab('history', 'History'),
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
          color: isActive ? Colors.blue : Colors.white,
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
                _buildStatCard('Total Spent', '₹2,450', Icons.attach_money, Colors.red[100]!, Colors.red),
                _buildStatCard('Active Req', '3', Icons.book, Colors.blue[100]!, Colors.blue),
                _buildStatCard('Tutors', '8', Icons.people, Colors.purple[100]!, Colors.purple),
                _buildStatCard('Completed', '12', Icons.check_circle, Colors.green[100]!, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => appState.setScreen('upload'),
                          icon: const Icon(Icons.add),
                          label: const Text('Post Request'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[50], foregroundColor: Colors.purple),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => appState.setScreen('search'),
                          icon: const Icon(Icons.search),
                          label: const Text('Find Tutors'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[50], foregroundColor: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                   _buildActivityItem(Icons.message, Colors.blue, 'New response', 'Kalyani M. responded to your math request', '2h ago'),
                   const Divider(height: 24),
                   _buildActivityItem(Icons.check_circle, Colors.green, 'Session completed', 'Java programming help with Arjun K.', '1d ago'),
                ],
              ),
            ),
          ],
        );
      case 'requests':
        return Column(
          children: [
            _buildRequestCard('Need help with Calculus', 'Math', '₹300', 'Active'),
            _buildRequestCard('Java OOP concepts', 'Programming', '₹250', 'In Progress'),
          ],
        );
      case 'tutors':
        return const Center(child: Text('Use Search to find tutors'));
      case 'history':
        return Column(
          children: [
            _buildHistoryItem('Math Tutoring', 'Kalyani M.', '₹300'),
            _buildHistoryItem('Python Help', 'Arjun K.', '₹200'),
          ],
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

  Widget _buildRequestCard(String title, String subject, String price, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(fontSize: 10, color: Colors.blue[700])),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String service, String tutor, String price) {
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
              Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(tutor, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
