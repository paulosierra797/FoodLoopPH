import 'package:supabase_flutter/supabase_flutter.dart';

class FoodListingService {
  final SupabaseClient _supabase;
  FoodListingService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  /// Calls the `get_user_food_listings` Postgres function with optional filters.
  ///
  /// Parameters:
  /// - [postedBy]: (UUID string) if provided, function will scope to that user's listings (auth-scoped use-case).
  /// - [status]: filter by listing status (e.g., 'available', 'removed')
  /// - [limit], [offset]: pagination
  /// - [orderBy]: one of ('created_at','food_name','user_email')
  /// - [orderDir]: 'asc' or 'desc'
  Future<List<Map<String, dynamic>>> fetchJoinedUserFoodListings({
    String? postedBy,
    String? status,
    int? limit,
    int? offset,
    String? orderBy,
    String? orderDir,
  }) async {
    final params = <String, dynamic>{
      'p_posted_by': postedBy,
      'p_status': status,
      'p_limit': limit,
      'p_offset': offset ?? 0,
      'p_order_by': orderBy ?? 'created_at',
      'p_order_dir': orderDir ?? 'desc',
    };

  final result = await _supabase.rpc('get_user_food_listings', params: params);
    if (result == null) return [];
    return List<Map<String, dynamic>>.from(result as List);
  }

  /// Convenience method to fetch listings for the currently authenticated user
  Future<List<Map<String, dynamic>>> fetchMyListings({
    String? status,
    int? limit,
    int? offset,
    String? orderBy,
    String? orderDir,
  }) async {
    final params = <String, dynamic>{
      'p_status': status,
      'p_limit': limit,
      'p_offset': offset ?? 0,
      'p_order_by': orderBy ?? 'created_at',
      'p_order_dir': orderDir ?? 'desc',
    };

    final result = await _supabase.rpc('get_my_food_listings', params: params);
    if (result == null) return [];
    return List<Map<String, dynamic>>.from(result as List);
  }
}
