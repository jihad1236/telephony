import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telephony/telephony.dart';
import '../controllers/sms_controller.dart';

class SmsConversationView extends StatelessWidget {
  final String address;

  const SmsConversationView({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SmsController>();
    final msgs = controller.conversations[address] ?? [];
    final sorted = [...msgs]..sort((a, b) => (a.date ?? 0).compareTo(b.date ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${msgs.length} messages', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: sorted.isEmpty
          ? const Center(child: Text('No messages'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                return _MessageBubble(message: sorted[index]);
              },
            ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SmsMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.type == SmsType.MESSAGE_TYPE_SENT;
    final body = message.body ?? '';
    final date = message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : null;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSent ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSent ? 18 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: TextStyle(
                color: isSent ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            if (date != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: TextStyle(
                  color: isSent ? Colors.white70 : Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return time;
    }
    return '${date.day}/${date.month}/${date.year % 100} $time';
  }
}
