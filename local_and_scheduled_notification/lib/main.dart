import 'package:flutter/material.dart';
import 'package:local_and_scheduled_notification/home_page.dart';
import 'package:local_and_scheduled_notification/noti_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init notifications
  final NotiService notiService = NotiService();
  await notiService.initNotification(); // Ensure initialization completes before running the app

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
