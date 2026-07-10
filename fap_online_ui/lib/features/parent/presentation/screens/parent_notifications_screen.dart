import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/parent_models.dart';
import '../../provider/parent_notifications_provider.dart';
import '../../utils/display_utils.dart';

class ParentNotificationsScreen extends StatelessWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentNotificationsProvider>();

    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.notifications.isEmpty) {
      return _NotificationsError(
        message: provider.error!,
        onRetry: provider.load,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _UnreadBanner(count: provider.unreadCount),
          const SizedBox(height: 16),
          if (provider.notifications.isEmpty)
            const _NotificationsEmpty()
          else
            ...provider.notifications.map(
              (notification) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NotificationCard(
                  notification: notification,
                  onTap: notification.isRead ? null : () => provider.markAsRead(notification),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnreadBanner extends StatelessWidget {
  final int count;

  const _UnreadBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none_rounded, color: scheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 0
                  ? 'All notifications are read.'
                  : '$count unread notification${count == 1 ? '' : 's'} are waiting.',
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final ParentNotificationItem notification;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
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
                            displayText(notification.title),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!notification.isRead)
                          Text(
                            'New',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(displayText(notification.message)),
                    const SizedBox(height: 10),
                    Text(
                      formatDateTimeLabel(notification.sentAt),
                      style: Theme.of(context).textTheme.labelMedium,
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

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('Notifications will appear here when the backend returns records.'),
        ],
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NotificationsError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(
              'Could not load notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
