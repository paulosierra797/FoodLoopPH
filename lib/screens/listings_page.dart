// ListingsPage widget
import 'package:flutter/material.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Listings")),
      body:
          Center(child: Text("Listings Page", style: TextStyle(fontSize: 24))),
    );
  }
}
