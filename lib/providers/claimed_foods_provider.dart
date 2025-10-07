import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the list of foods claimed by the currently authenticated user.
final claimedFoodsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) {
    return []; // Return empty list if user is not authenticated
  }

  final response = await supabase.rpc('get_claimed_foods', params: {
    'user_id': user.id,
  });

  return List<Map<String, dynamic>>.from(response);
});