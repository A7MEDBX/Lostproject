import 'package:flutter/material.dart';
import '../../mock_backend/services/notification_service.dart';
import '../../mock_backend/mocks/notifications.mock.dart';
import '../../mock_backend/mocks/users.mock.dart';

/// Notifications Screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<MockNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final response = await NotificationService.getUserNotifications(currentMockUser.id);
    if (mounted) {
      setState(() {
        _notifications = response.data ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Icon at top
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                size: 40,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Stay updated with all your notifications',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 24),

            // Notifications List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A3D91)))
                  : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationItem(notification);
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Mark all as read button
            if (_notifications.any((n) => !n.isRead))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () async {
                      await NotificationService.markAllAsRead(currentMockUser.id);
                      setState(() {
                        for (var n in _notifications) {
                          n.isRead = true;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8B7355)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark All as Read',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B7355),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Bottom help text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need help? ',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to help/support
                    },
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B7355),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(MockNotification notification) {
    Color iconColor;
    IconData icon;
    switch (notification.type) {
      case 'match_found': iconColor = Colors.orange; icon = Icons.stars; break;
      case 'contact_request': iconColor = const Color(0xFF0A3D91); icon = Icons.person_add; break;
      case 'contact_accepted': iconColor = Colors.green; icon = Icons.check_circle; break;
      case 'post_resolved': iconColor = Colors.grey; icon = Icons.task_alt; break;
      default: iconColor = const Color(0xFF8B7355); icon = Icons.notifications; break;
    }
    return Container(
      color: notification.isRead ? Colors.white : Colors.grey[50],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(child: Text(notification.displayTitle, style: TextStyle(fontSize: 15, fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600))),
            if (!notification.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF0A3D91), shape: BoxShape.circle)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.displayMessage, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(_timeAgo(notification.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        onTap: () async {
          await NotificationService.markAsRead(notification.id);
          setState(() { notification.isRead = true; });
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
