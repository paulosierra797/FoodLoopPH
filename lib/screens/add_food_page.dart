// AddFoodPage widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFoodPage extends StatelessWidget {
  const AddFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Food Donation", style: GoogleFonts.poppins()),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Food Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Pickup Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  minimumSize: Size(double.infinity, 50)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Food Donation Added!")),
                );
              },
              child: Text("Submit", style: GoogleFonts.poppins(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
