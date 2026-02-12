import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isStudent = appState.userType == 'student';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isStudent
                      ? [const Color(0xFFC084FC), const Color(0xFF60A5FA)]
                      : [const Color(0xFF2DD4BF), const Color(0xFF4ADE80)],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      isStudent ? 'TT' : 'KM',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isStudent ? Colors.purple : Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStudent ? 'Tanisha Tulsi' : 'Kalyani Mehta',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                         isStudent ? 'B.Tech CS • 3rd Year' : 'B.Tech Math • 4th Year',
                         style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                    style: IconButton.styleFrom(backgroundColor: Colors.white24),
                  )
                ],
              ),
            ),

            // Stats
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStat('Completed', '24', Icons.check_circle),
                    const SizedBox(width: 12),
                    _buildStat('Rating', '4.8', Icons.star),
                    const SizedBox(width: 12),
                    _buildStat('Reviews', '18', Icons.message),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Verification
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isStudent ? Colors.blue[50] : Colors.teal[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isStudent ? Colors.blue[100]! : Colors.teal[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: isStudent ? Colors.blue : Colors.teal),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isStudent ? 'Verified Student' : 'Verified Peer Tutor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isStudent ? Colors.blue[900] : Colors.teal[900],
                              ),
                            ),
                            Text(
                              'ID and records verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: isStudent ? Colors.blue[700] : Colors.teal[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dashboard Button
                  GestureDetector(
                    onTap: () => appState.setScreen(isStudent ? 'student-admin' : 'tutor-admin'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                         boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                         ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isStudent ? Colors.purple[100] : Colors.teal[100],
                            child: Icon(Icons.dashboard, color: isStudent ? Colors.purple : Colors.teal),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isStudent ? 'Student Dashboard' : 'Tutor Dashboard',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text('Manage requests & progress', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Settings
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('EduWallet'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => appState.setScreen('payment'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Manage Students'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => appState.setScreen('student-management'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => appState.setScreen('settings'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: const Text('Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => appState.setScreen('support'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => appState.setScreen('about'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () => appState.logout(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route, AppState appState) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => appState.setScreen(route),
    );
  }
}
