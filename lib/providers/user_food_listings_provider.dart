import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodloopph/services/food_listing_service.dart';

/// Parameter object for listing queries
class UserListingQuery {
  final String? postedBy;
  final String? status;
  final int? limit;
  final int? offset;
  final String? orderBy;
  final String? orderDir;

  UserListingQuery({this.postedBy, this.status, this.limit, this.offset, this.orderBy, this.orderDir});
}

final userFoodListingsProvider = FutureProvider.family<List<Map<String, dynamic>>, UserListingQuery>((ref, q) async {
  final service = FoodListingService();
  return service.fetchJoinedUserFoodListings(
    postedBy: q.postedBy,
    status: q.status,
    limit: q.limit,
    offset: q.offset,
    orderBy: q.orderBy,
    orderDir: q.orderDir,
  );
});
