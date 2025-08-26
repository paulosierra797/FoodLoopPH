// HomePage widget (donations list)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../supabase_client.dart';

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
      endDrawer: Drawer(
  child: SafeArea(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    Text("user@gmail.com",
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[700]),
            ],
          ),
        ),
        SizedBox(height: 24),
        Divider(),
        ListTile(
          leading: Icon(Icons.home, color: Colors.grey[700]),
          title: Text("Home", style: GoogleFonts.poppins()),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text("ACTIVITY",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600)),
        ),
        ListTile(
          leading: Icon(Icons.star, color: Colors.grey[700]),
          title: Text("My Watchlist", style: GoogleFonts.poppins()),
          onTap: () {
            // TODO: Navigate
          },
        ),
        ListTile(
          leading: Icon(Icons.list, color: Colors.grey[700]),
          title: Text("My Listings", style: GoogleFonts.poppins()),
          onTap: () {
            // TODO: Navigate
          },
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text("SETTINGS",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600)),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.grey[700]),
          title: Text("Profile", style: GoogleFonts.poppins()),
          onTap: () {
            // TODO: Navigate
          },
        ),
        ListTile(
          leading: Icon(Icons.notifications, color: Colors.grey[700]),
          title: Text("Notification Settings", style: GoogleFonts.poppins()),
          onTap: () {
            // TODO: Navigate
          },
        ),
        ListTile(
          leading: Icon(Icons.info, color: Colors.grey[700]),
          title: Text("About", style: GoogleFonts.poppins()),
          onTap: () {
            // TODO: Navigate
          },
        ),
        ListTile(
          leading: Icon(Icons.lock, color: Colors.grey[700]),
          title: Text("Change Password", style: GoogleFonts.poppins()),
          onTap: () {
            // TODO: Navigate
          },
        ),
        // 🔹 Sign Out button (always visible, scrollable if needed)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.logout, size: 20),
              label: Text("Sign Out",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onPressed: () async {
                await supabase.auth.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ),
      ],
    ),
  ),
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
