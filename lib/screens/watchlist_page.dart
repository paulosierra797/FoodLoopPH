// WatchlistPage widget
import 'package:flutter/material.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Watchlist")),
      body:
          Center(child: Text("Watchlist Page", style: TextStyle(fontSize: 24))),
    );
  }
}
