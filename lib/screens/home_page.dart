// HomePage widget (donations list)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> donations = [
    {
      "name": "McDo Pala-pala",
      "address": "822 Aguinaldo Hwy, Dasmariñas, 4114 Cavite",
      "food": "Burger & Fries",
      "img": "https://i.imgur.com/3ZQ3Z5F.png"
    },
    {
      "name": "Balinsasayaw",
      "address": "822 Aguinaldo Hwy, Dasmariñas, 4114 Cavite",
      "food": "Pizza",
      "img": "https://i.imgur.com/jX0Xn5G.png"
    },
    {
      "name": "Jabi Caloocan",
      "address": "822 Aguinaldo Hwy, Dasmariñas, 4114 Cavite",
      "food": "Fried Chicken",
      "img": "https://i.imgur.com/IDQK9tC.png"
    },
  ];

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.amber[700],
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good morning, User",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text("Dasmariñas", style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications, size: 26, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final item = donations[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item["img"]!,
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["name"]!,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item["address"]!,
                                style: GoogleFonts.poppins(fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: -6,
                              children: [
                                Chip(label: Text("Quantity: 4 pcs")),
                                Chip(label: Text("Food type: "+(item['food']??''))),
                              ],
                            )
                          ]),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {},
                      child: const Text("Accept"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
