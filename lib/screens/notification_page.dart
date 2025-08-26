// NotificationPage widget
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Center(
          child: Text("Notification Settings Page",
              style: TextStyle(fontSize: 24))),
    );
  }
}
