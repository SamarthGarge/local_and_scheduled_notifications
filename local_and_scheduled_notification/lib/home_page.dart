import 'package:flutter/material.dart';
import 'package:local_and_scheduled_notification/noti_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // button -> show notification now
            ElevatedButton(
              onPressed: () {
                NotiService().showNotification(
                  title: "Title",
                  body: "Body",
                );
              },
              child: const Text("Send Noti"),
            ),

            // button -> schedule notification for later
            ElevatedButton(
              onPressed: () async {
                await NotiService().scheduleNotification(
                  title: "Title",
                  body: "Body",
                  hour: 1, // 1pm
                  minute: 0,
                );
              },
              child: const Text("Scheduled Noti"),
            ),
          ],
        ),
      ),
    );
  }
}
