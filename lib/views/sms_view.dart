import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telephony/telephony.dart';
import '../controllers/sms_controller.dart';
import 'sms_conversation_view.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.loadMessages,
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasPermission.value) {
          return _PermissionDeniedView(onRetry: controller.requestPermissionsAndLoad);
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(controller.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadMessages,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.conversations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages found', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final addresses = controller.conversationAddresses;
        return ListView.builder(
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            final msgs = controller.conversations[address]!;
            return _ConversationCard(
              address: address,
              messages: msgs,
              onTap: () => Get.to(() => SmsConversationView(address: address)),
            );
          },
        );
      }),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 72, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Permission Required',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app needs SMS and phone access to display your messages.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.security),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final String address;
  final List<SmsMessage> messages;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.address,
    required this.messages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final latest = messages.first;
    final body = latest.body ?? '';
    final date = latest.date != null
        ? DateTime.fromMillisecondsSinceEpoch(latest.date!)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            address[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          address,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (date != null)
              Text(
                _formatDate(date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year % 100}';
  }
}
