import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification.dart';
import '../../core/config/routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) return const SizedBox();
              
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'mark_all_read') {
                    await provider.markAllAsRead();
                  } else if (value == 'clear_all') {
                    _showClearAllDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: 12),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Clear all'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when something happens',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationCard(notification, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, NotificationProvider provider) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          provider.markAsRead(notification.id);
          _handleNotificationTap(notification);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          color: notification.isRead ? Colors.transparent : Colors.blue.shade50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.isRead 
                      ? Colors.grey.shade200 
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notification.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeago.format(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // More actions
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {
                  _showNotificationOptions(notification, provider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Navigate based on notification type/data
    final screen = notification.data['screen'];
    
    if (screen != null) {
      switch (screen.toString()) {
        case 'BookingDetail':
          final bookingId = notification.data['bookingId'];
          if (bookingId != null) {
            Navigator.of(context).pushNamed(
              Routes.booking,
              arguments: {'bookingId': bookingId},
            );
          }
          break;
          
        case 'ListingDetail':
          final listingId = notification.data['listingId'];
          if (listingId != null) {
            Navigator.of(context).pushNamed(
              Routes.listingDetail,
              arguments: listingId,
            );
          }
          break;
          
        case 'WriteReview':
          final bookingId = notification.data['bookingId'];
          final listingId = notification.data['listingId'];
          if (bookingId != null && listingId != null) {
            // Navigate to review screen
            Navigator.of(context).pushNamed(
              '/write-review',
              arguments: {
                'bookingId': bookingId,
                'listingId': listingId,
              },
            );
          }
          break;
          
        default:
          break;
      }
    }
  }

  void _showNotificationOptions(AppNotification notification, NotificationProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.done),
                title: const Text('Mark as read'),
                onTap: () {
                  provider.markAsRead(notification.id);
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                provider.deleteNotification(notification.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}






