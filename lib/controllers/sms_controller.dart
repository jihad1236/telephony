import 'package:get/get.dart';
import 'package:telephony/telephony.dart';

class SmsController extends GetxController {
  final Telephony _telephony = Telephony.instance;

  final RxList<SmsMessage> messages = <SmsMessage>[].obs;
  final RxMap<String, List<SmsMessage>> conversations = <String, List<SmsMessage>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final RxString error = ''.obs;

  List<String> get conversationAddresses {
    final addresses = conversations.keys.toList();
    addresses.sort((a, b) {
      final aDate = conversations[a]!.first.date ?? 0;
      final bDate = conversations[b]!.first.date ?? 0;
      return bDate.compareTo(aDate);
    });
    return addresses;
  }

  @override
  void onInit() {
    super.onInit();
    requestPermissionsAndLoad();
  }

  Future<void> requestPermissionsAndLoad() async {
    isLoading.value = true;
    error.value = '';

    try {
      final granted = await _telephony.requestPhoneAndSmsPermissions;
      hasPermission.value = granted ?? false;

      if (hasPermission.value) {
        await loadMessages();
      }
    } catch (e) {
      error.value = 'Permission request failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    error.value = '';

    try {
      final inbox = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.TYPE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      List<SmsMessage> sent = [];
      try {
        sent = await _telephony.getSentSms(
          columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.TYPE],
          sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
        );
      } catch (_) {}

      final all = [...inbox, ...sent];
      all.sort((a, b) => (b.date ?? 0).compareTo(a.date ?? 0));
      messages.assignAll(all);

      final grouped = <String, List<SmsMessage>>{};
      for (final msg in all) {
        final addr = msg.address ?? 'Unknown';
        (grouped[addr] ??= []).add(msg);
      }
      conversations.assignAll(grouped);
    } catch (e) {
      error.value = 'Failed to load messages: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
