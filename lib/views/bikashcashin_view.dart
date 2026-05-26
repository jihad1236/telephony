import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_reader/controllers/sms_controller.dart';
import 'package:telephony/telephony.dart';

class BkashCashInView extends GetView<SmsController> {
  const BkashCashInView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('bKash History',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFE2136E),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            Obx(() => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.loadMessages(),
                  )),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: 'Cash In'),
              Tab(text: 'Cash Out'),
              Tab(text: 'Received'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _BkashList(
                messages: controller.bkashCashInMessages,
                type: _BkashType.cashIn,
              ),
              _BkashList(
                messages: controller.bkashCashOutMessages,
                type: _BkashType.cashOut,
              ),
              _BkashList(
                messages: controller.bkashReceivedMessages,
                type: _BkashType.received,
              ),
            ],
          );
        }),
      ),
    );
  }
}

enum _BkashType { cashIn, cashOut, received }

class _BkashList extends StatelessWidget {
  final List<SmsMessage> messages;
  final _BkashType type;

  const _BkashList({required this.messages, required this.type});

  String get _emptyLabel {
    switch (type) {
      case _BkashType.cashIn:
        return 'No Cash In messages found';
      case _BkashType.cashOut:
        return 'No Cash Out messages found';
      case _BkashType.received:
        return 'No received messages found';
    }
  }

  Color get _amountColor {
    switch (type) {
      case _BkashType.cashIn:
        return const Color(0xFF3ABB41);
      case _BkashType.cashOut:
        return const Color(0xFFE2136E);
      case _BkashType.received:
        return const Color(0xFF3ABB41);
    }
  }

  Map<String, String> _parse(String body, _BkashType type) {
    String amount = '';
    String party = '';
    String trxId = '';
    String balance = '';

    switch (type) {
      case _BkashType.cashIn:
        amount = RegExp(r'Cash In Tk ([\d,]+\.?\d*)').firstMatch(body)?.group(1) ?? '';
        party = RegExp(r'from (\d+)').firstMatch(body)?.group(1) ?? '';
      case _BkashType.cashOut:
        amount = RegExp(r'^Cash Out Tk ([\d,]+\.?\d*)').firstMatch(body)?.group(1) ?? '';
        party = RegExp(r'(?:at|from|to) ([A-Za-z0-9 ]+?)(?:\.|,|\sTrxID)').firstMatch(body)?.group(1)?.trim() ?? '';
      case _BkashType.received:
        amount = RegExp(r'received Tk ([\d,]+\.?\d*)').firstMatch(body)?.group(1) ?? '';
        party = RegExp(r'from (\d+)').firstMatch(body)?.group(1) ?? '';
    }

    trxId = RegExp(r'TrxID (\S+)').firstMatch(body)?.group(1) ?? '';
    balance = RegExp(r'Balance Tk ([\d,]+\.?\d*)').firstMatch(body)?.group(1) ?? '';

    return {'amount': amount, 'party': party, 'trxId': trxId, 'balance': balance};
  }

  String get _partyLabel {
    switch (type) {
      case _BkashType.cashIn:
      case _BkashType.received:
        return 'From';
      case _BkashType.cashOut:
        return 'At';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_emptyLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final m = messages[index];
        final date = m.date != null
            ? DateTime.fromMillisecondsSinceEpoch(m.date!).toLocal()
            : null;
        final body = m.body ?? '';
        final parsed = _parse(body, type);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
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
                      'Tk ${parsed['amount']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _amountColor,
                      ),
                    ),
                    if (date != null)
                      Text(
                        '${date.day}/${date.month}/${date.year}  '
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if ((parsed['party'] ?? '').isNotEmpty)
                  _InfoRow(label: _partyLabel, value: parsed['party']!),
                if ((parsed['balance'] ?? '').isNotEmpty)
                  _InfoRow(label: 'Balance', value: 'Tk ${parsed['balance']}'),
                if ((parsed['trxId'] ?? '').isNotEmpty)
                  _InfoRow(label: 'TrxID', value: parsed['trxId']!),
              ],
            ),
          ),
        );
      },
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
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
