import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../main.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setScreen('home'),
        ),
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () async {
                await _notificationService.markAllAsRead(user.uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              child: Text('Mark all read', style: GoogleFonts.inter(fontSize: 12)),
            ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Please login to view notifications', style: GoogleFonts.inter(color: Colors.grey)),
                ],
              ),
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notificationService.getNotifications(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 100, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No notifications yet', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('We\'ll notify you when something happens', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ).animate().fadeIn(),
                  );
                }

                final notifications = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: index * 50))
                        .slideX(begin: -0.2, end: 0);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Notification';
    final body = notification['body'] ?? '';
    final isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? 'general';
    final timestamp = notification['timestamp'] as Timestamp?;
    final notificationId = notification['id'];

    String timeAgo = 'Just now';
    if (timestamp != null) {
      final date = timestamp.toDate();
      final difference = DateTime.now().difference(date);
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      }
    }

    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'payment':
        icon = Icons.account_balance_wallet;
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'assignment':
        icon = Icons.assignment;
        iconColor = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'welcome':
        icon = Icons.celebration;
        iconColor = Colors.purple;
        bgColor = Colors.purple.shade50;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.orange;
        bgColor = Colors.orange.shade50;
    }

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _notificationService.deleteNotification(notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // In a real app, you'd restore the notification here
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () async {
          if (!isRead) {
            await _notificationService.markAsRead(notificationId);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
