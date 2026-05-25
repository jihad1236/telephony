import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/sms_controller.dart';
import 'views/sms_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SMS Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SmsView(),
      initialBinding: BindingsBuilder(() {
        Get.put(SmsController());
      }),
    );
  }
}
