import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for fetching notifications from the database
final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    return []; // Return empty list if user is not authenticated
  }

  try {
    final response = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(50); // Limit to 50 most recent notifications

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    // Return empty list if there's an error (table might not exist yet)
    return [];
  }
});

/// Provider for unread notifications count
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    return 0;
  }

  try {
    final response = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('is_read', false);

    return response.length;
  } catch (e) {
    // Return 0 if there's an error
    return 0;
  }
});