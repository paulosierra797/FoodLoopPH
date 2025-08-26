// SearchPage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Donations", style: GoogleFonts.poppins()),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search food or donor...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.fastfood, color: Colors.amber[700]),
                    title: Text("Burger from McDo"),
                    subtitle: Text("Dasmariñas"),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_pizza, color: Colors.amber[700]),
                    title: Text("Pizza from Balinsasayaw"),
                    subtitle: Text("Dasmariñas"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
