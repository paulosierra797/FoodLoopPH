import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardMetrics {
  final int totalDonations; // total successful claims
  final int activeListings; // listings with status = 'available'
  final int peopleHelped; // unique users who shared (posted) at least one food (contributors)

  const DashboardMetrics({
    required this.totalDonations,
    required this.activeListings,
    required this.peopleHelped,
  });
}final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
	final supabase = Supabase.instance.client;

	int totalDonations = 0;
	int activeListings = 0;
	int peopleHelped = 0;

	// Count successful claims (food_claims rows)
	try {
		final claimsRows = await supabase.from('food_claims').select('id');
		totalDonations = (claimsRows as List).length;
	} catch (e) {
		debugPrint('dashboard: failed to count claims: $e');
	}

	// Count active listings (status = 'available')
	try {
		final activeRows = await supabase
				.from('food_listings')
				.select('id')
				.eq('status', 'available');
		activeListings = (activeRows as List).length;
	} catch (e) {
		debugPrint('dashboard: failed to count active listings: $e');
	}

  // Count unique contributors (users who shared a food): distinct posted_by in food_listings
  try {
    final posters = await supabase.from('food_listings').select('posted_by');
    final set = <String>{};
    for (final row in (posters as List)) {
      final v = row['posted_by'];
      if (v != null) set.add(v.toString());
    }
    peopleHelped = set.length;
  } catch (e) {
    debugPrint('dashboard: failed to count people who help (unique contributors): $e');
  }	return DashboardMetrics(
		totalDonations: totalDonations,
		activeListings: activeListings,
		peopleHelped: peopleHelped,
	);
});

