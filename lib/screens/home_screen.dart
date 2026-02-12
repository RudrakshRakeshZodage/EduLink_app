import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = FirebaseAuth.instance.currentUser;
    final userType = appState.userType;
    final isStudent = userType == 'student';

    final trendingServices = [
      {'title': 'Mathematics Assignment Help', 'price': '₹150', 'rating': 4.8, 'tutor': 'Kalyani M.'},
      {'title': 'Python Programming Notes', 'price': '₹200', 'rating': 4.9, 'tutor': 'Arjun K.'},
      {'title': 'English Essay Writing', 'price': '₹100', 'rating': 4.7, 'tutor': 'Janhavi S.'}
    ];

    final studentRequests = [
      {'title': 'Calculus Integration Help', 'price': '₹300', 'rating': 4.8, 'tutor': 'Tanisha T.'},
      {'title': 'Java Doubt Clearing', 'price': '₹250', 'rating': 4.7, 'tutor': 'Rohit K.'},
      {'title': 'Essay Writing Help', 'price': '₹150', 'rating': 4.6, 'tutor': 'Priya S.'}
    ];

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isStudent
                    ? [const Color(0xFFC084FC), const Color(0xFF60A5FA)] // Purple to Blue
                    : [const Color(0xFF2DD4BF), const Color(0xFF4ADE80)], // Teal to Green
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${isStudent ? 'Tanisha' : 'Kalyani'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isStudent ? 'Ready for peer learning?' : 'Ready to help others?',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isStudent ? 'STUDENT MODE' : 'TUTOR MODE',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => appState.setScreen('notifications'),
                      child: StreamBuilder<int>(
                        stream: user != null 
                            ? NotificationService().getUnreadCount(user.uid)
                            : Stream.value(0),
                        builder: (context, snapshot) {
                          final unreadCount = snapshot.data ?? 0;
                          return Stack(
                            children: [
                              const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      unreadCount > 9 ? '9+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => appState.setScreen('search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[400]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isStudent
                                ? 'Find peer tutors, notes...'
                                : 'Find students needing help...',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Quick Actions
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildQuickAction(Icons.menu_book, 'Study Notes', Colors.blue, () => appState.setScreen('search'))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction(Icons.group, 'Group Study', Colors.purple, () => appState.setScreen('group-study'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildQuickAction(Icons.calculate, 'Math Help', Colors.teal, () => appState.setScreen('search'))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction(Icons.smart_toy, 'AI Tutor', Colors.deepPurple, () => appState.setScreen('ai-tutor'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildQuickAction(
                            Icons.search, 
                            isStudent ? 'Find Tutor' : 'Find Student', 
                            Colors.orange,
                            () => appState.setScreen('search')
                        )),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()), // Empty space
                  ],
                ),

                const SizedBox(height: 32),

                // Trending Services
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isStudent ? 'Available Tutors' : 'Students Need Help',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Hot', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                
                ...(isStudent ? trendingServices : studentRequests).map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildServiceCard(service, appState),
                )),

                const SizedBox(height: 24),

                // Featured Request
                GestureDetector(
                  onTap: () => appState.setScreen('chat'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isStudent
                            ? [const Color(0xFFEFF6FF), const Color(0xFFFAF5FF)]
                            : [const Color(0xFFF0FDFA), const Color(0xFFF0FDF4)],
                      ),
                      border: Border.all(
                        color: isStudent ? Colors.blue[100]! : Colors.teal[100]!,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: isStudent ? Colors.blue : Colors.teal),
                            const SizedBox(width: 4),
                            Text(
                              isStudent ? 'Tutor Near You' : 'Student Near You',
                              style: TextStyle(
                                color: isStudent ? Colors.blue : Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isStudent ? 'Expert Math Tutor Available' : 'Urgent Calculus Help Needed',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isStudent
                              ? 'Kalyani from IIT Bombay - 4.9★ rating'
                              : 'Tanisha needs help with Integration',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isStudent ? '₹250/hr' : '₹300 budget',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => appState.setScreen('chat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isStudent ? Colors.blue : Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: const Text('Contact'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, MaterialColor color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, AppState appState) {
    return GestureDetector(
      onTap: () => appState.setScreen('chat'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  service['price'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.purple[100],
                      child: Text(
                        (service['tutor'] as String)[0],
                        style: TextStyle(fontSize: 10, color: Colors.purple[700], fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service['tutor'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      service['rating'].toString(),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
