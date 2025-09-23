import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/food_listings_provider.dart';

class ListingsPage extends ConsumerWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(foodListingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text("My Listings")),
      body: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return Center(child: Text("No listings found."));
          }
          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final item = listings[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['description'] ?? ''),
                  trailing: Text(item['quantity'] ?? ''),
                  // Add more fields as needed
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
