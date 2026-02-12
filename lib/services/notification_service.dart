import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send notification to a user
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'recipientId': recipientId,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✓ Notification sent to $recipientId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Get user's notifications
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      print('✓ All notifications marked as read');
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Send welcome notification to new users
  Future<void> sendWelcomeNotification(String userId) async {
    await sendNotification(
      recipientId: userId,
      title: '🎉 Welcome to EduLink!',
      body: 'Start your learning journey by exploring tutors and study groups.',
      type: 'welcome',
    );
  }

  /// Send payment notification
  Future<void> sendPaymentNotification({
    required String recipientId,
    required String senderName,
    required double amount,
    required bool isCredit,
  }) async {
    await sendNotification(
      recipientId: recipientId,
      title: isCredit ? '💰 Money Received' : '📤 Payment Sent',
      body: isCredit
          ? '$senderName sent you ₹${amount.toStringAsFixed(2)}'
          : 'You sent ₹${amount.toStringAsFixed(2)} to $senderName',
      type: 'payment',
      data: {'amount': amount, 'sender': senderName},
    );
  }

  /// Send assignment notification
  Future<void> sendAssignmentNotification({
    required String recipientId,
    required String tutorName,
    required String assignmentTitle,
  }) async {
    await sendNotification(
      recipientId: recipientId,
      title: '📚 New Assignment',
      body: '$tutorName assigned: $assignmentTitle',
      type: 'assignment',
    );
  }
}
