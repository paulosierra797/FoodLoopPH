import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final foodListingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Get food listings with claimer information if available
  try {
    final response = await supabase
        .from('food_listings')
        .select('*, claimer:claimed_by(id, first_name, last_name, email)')
        .order('created_at', ascending: false);
    
    List<Map<String, dynamic>> listings = List<Map<String, dynamic>>.from(response);
    
    // Process claimer information for claimed items
    for (int i = 0; i < listings.length; i++) {
      final listing = listings[i];
      if (listing['status'] == 'claimed' && listing['claimer'] != null) {
        final claimerInfo = listing['claimer'];
        listings[i]['claimer_id'] = claimerInfo['id'];
        listings[i]['claimer_name'] = '${claimerInfo['first_name'] ?? ''} ${claimerInfo['last_name'] ?? ''}'.trim();
        listings[i]['claimer_email'] = claimerInfo['email'];
      } else if (listing['status'] == 'claimed' && listing['claimed_by'] != null) {
        // If the join didn't work, use the claimed_by field directly
        listings[i]['claimer_id'] = listing['claimed_by'];
        listings[i]['claimer_name'] = 'User'; // Will be populated by the RPC function
      }
    }
    
    return listings;
  } catch (e) {
    // Fallback to basic query if the join fails
    debugPrint('Failed to fetch with claimer info, falling back to basic query: $e');
    final response = await supabase
        .from('food_listings')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
});
