import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/notification_provider.dart';
import '../../notifiers/notification_notifier.dart';
import '../../models/notification_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        subtitle: 'Stay updated with your shop',
        showBackButton: true,
        actions: [
          if (notificationState.notifications.isNotEmpty)
            CustomAppBar.buildActionButton(
              icon: Iconsax.task_square,
              iconColor: AppColors.primary,
              onTap: notifier.markAllAsRead,
            ),
          if (notificationState.notifications.isNotEmpty)
            CustomAppBar.buildActionButton(
              icon: Iconsax.trash,
              iconColor: Colors.redAccent,
              onTap: () => _showClearDialog(context, notifier),
            ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: notificationState.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationState.notifications[index];
                    return _buildNotificationCard(notification, notifier);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.notification_bing,
              size: 48,
              color: AppColors.primary.withAlpha(150),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: AppTextStyles.subHeader,
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll notify you when something\nimportant happens.',
            textAlign: TextAlign.center,
            style: AppTextStyles.description,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationNotifier notifier) {
    final isUnread = !notification.isRead;
    
    IconData getIcon() {
      switch (notification.type) {
        case 'order':
          return Iconsax.box;
        case 'admin':
          return Iconsax.security_user;
        case 'system':
        default:
          return Iconsax.info_circle;
      }
    }

    Color getIconColor() {
      switch (notification.type) {
        case 'order':
          return AppColors.success;
        case 'admin':
          return Colors.orangeAccent;
        case 'system':
        default:
          return AppColors.primary;
      }
    }

    return GestureDetector(
      onTap: () {
        if (isUnread) notifier.markAsRead(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? AppColors.primary.withAlpha(50) : AppColors.divider.withAlpha(50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(isUnread ? 10 : 5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getIconColor().withAlpha(isUnread ? 30 : 15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(getIcon(), color: getIconColor(), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isUnread ? AppColors.textSecondary : AppColors.textTertiary,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary.withAlpha(200),
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

  void _showClearDialog(BuildContext context, NotificationNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear Notifications', style: AppTextStyles.cardTitle),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
