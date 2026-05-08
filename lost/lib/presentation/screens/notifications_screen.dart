import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/api_constants.dart';

/// Notifications Screen — wired to real backend API
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(tokenProvider: AuthService.instance.getIdToken);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await _apiClient.get(ApiConstants.notificationsEndpoint);
      final List<dynamic> raw = response['data'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _notifications = raw.map((n) => n as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String id, int index) async {
    try {
      await _apiClient.patch(
        '${ApiConstants.notificationsEndpoint}/$id/read',
        body: {},
      );
      if (mounted) {
        setState(() => _notifications[index]['is_read'] = true);
      }
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await _apiClient.post(
        ApiConstants.notificationReadAllEndpoint,
        body: {},
      );
      if (mounted) {
        setState(() {
          for (var n in _notifications) {
            n['is_read'] = true;
          }
        });
      }
    } catch (_) {}
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

            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

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
                              Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          color: const Color(0xFF0A3D91),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, _s) => Divider(height: 1, color: Colors.grey[300]),
                            itemBuilder: (context, index) =>
                                _buildNotificationItem(_notifications[index], index),
                          ),
                        ),
            ),

            const SizedBox(height: 16),

            // Mark all as read button
            if (_notifications.any((n) => n['is_read'] == false))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _markAllAsRead,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0A3D91)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark All as Read',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A3D91),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Need help? ', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/support'),
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

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final type = notification['type'] as String? ?? 'info';
    final isRead = notification['is_read'] as bool? ?? false;
    final createdAt = notification['created_at'] as String? ?? '';

    Color iconColor;
    IconData icon;
    String title;
    String message;

    switch (type) {
      case 'match_found':
        iconColor = Colors.orange;
        icon = Icons.stars;
        title = 'Match Found';
        message = 'A potential match was found for your item.';
        break;
      case 'contact_request':
        iconColor = const Color(0xFF0A3D91);
        icon = Icons.person_add;
        title = 'Contact Request';
        message = 'Someone wants to contact you about an item.';
        break;
      case 'contact_accepted':
        iconColor = Colors.green;
        icon = Icons.check_circle;
        title = 'Request Accepted';
        message = 'Your contact request was accepted.';
        break;
      case 'post_resolved':
        iconColor = Colors.grey;
        icon = Icons.task_alt;
        title = 'Post Resolved';
        message = 'An item you were following was resolved.';
        break;
      default:
        iconColor = const Color(0xFF8B7355);
        icon = Icons.notifications;
        title = 'Notification';
        message = 'You have a new notification.';
    }

    return Container(
      color: isRead ? Colors.white : Colors.grey[50],
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF0A3D91), shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(_timeAgo(createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        onTap: () {
          if (!isRead) _markAsRead(notification['id'] as String, index);
        },
      ),
    );
  }

  String _timeAgo(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
