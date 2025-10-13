import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final foodListingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Get food listings - use basic query since schema doesn't have proper FK relationships set up
  try {
    final response = await supabase
        .from('food_listings')
        .select()
        .order('created_at', ascending: false);
    
    List<Map<String, dynamic>> listings = List<Map<String, dynamic>>.from(response);
    
    // For claimed items, try to get claimer info separately if needed
    for (int i = 0; i < listings.length; i++) {
      final listing = listings[i];
      if (listing['status'] == 'claimed' && listing['claimed_by'] != null) {
        try {
          // Try to get claimer info from users table
          final claimerInfo = await supabase
              .from('users')
              .select('id, first_name, last_name, email')
              .eq('id', listing['claimed_by'])
              .maybeSingle();
          
          if (claimerInfo != null) {
            listings[i]['claimer_id'] = claimerInfo['id'];
            listings[i]['claimer_name'] = '${claimerInfo['first_name'] ?? ''} ${claimerInfo['last_name'] ?? ''}'.trim();
            listings[i]['claimer_email'] = claimerInfo['email'];
          } else {
            listings[i]['claimer_id'] = listing['claimed_by'];
            listings[i]['claimer_name'] = 'Unknown User';
          }
        } catch (e) {
          // If we can't get claimer info, just use the ID
          listings[i]['claimer_id'] = listing['claimed_by'];
          listings[i]['claimer_name'] = 'User';
          debugPrint('Could not fetch claimer info for ${listing['claimed_by']}: $e');
        }
      }
    }
    
    return listings;
  } catch (e) {
    debugPrint('Failed to fetch food listings: $e');
    return [];
  }
});
