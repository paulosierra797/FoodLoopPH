// AccountPage widget
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account")),
      body: Center(child: Text("Account Page", style: TextStyle(fontSize: 24))),
    );
  }
}
