import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_reader/controllers/sms_controller.dart';

class BkashCashInView extends GetView<SmsController> {
  const BkashCashInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('bKash Cash In History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE2136E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final msgs = controller.bkashCashInMessages;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (msgs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No bKash Cash In messages found',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: msgs.length,
          itemBuilder: (context, index) {
            final m = msgs[index];
            final date = m.date != null
                ? DateTime.fromMillisecondsSinceEpoch(m.date!).toLocal()
                : null;
            final body = m.body ?? '';

            final amountMatch = RegExp(r'Cash In Tk ([\d,]+\.\d+)').firstMatch(body);
            final fromMatch = RegExp(r'from (\d+)').firstMatch(body);
            final trxMatch = RegExp(r'TrxID (\S+)').firstMatch(body);
            final balanceMatch = RegExp(r'Balance Tk ([\d,]+\.\d+)').firstMatch(body);

            final amount = amountMatch?.group(1) ?? '';
            final from = fromMatch?.group(1) ?? '';
            final trxId = trxMatch?.group(1) ?? '';
            final balance = balanceMatch?.group(1) ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tk $amount',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 58, 187, 65)),
                        ),
                        if (date != null)
                          Text(
                            '${date.day}/${date.month}/${date.year}  '
                            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (from.isNotEmpty)
                      _InfoRow(label: 'From', value: from),
                    if (balance.isNotEmpty)
                      _InfoRow(label: 'Balance', value: 'Tk $balance'),
                    if (trxId.isNotEmpty)
                      _InfoRow(label: 'TrxID', value: trxId),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
