import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/user_food_listings_provider.dart';

/// Admin screen to view and manage user food listings
/// Utilizes:
/// - user_food_view (SQL VIEW for joined user + food data)
/// - get_user_food_listings (Stored Function)
class UserListingsAnalyticsScreen extends ConsumerStatefulWidget {
  const UserListingsAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListingsAnalyticsScreen> createState() => _UserListingsAnalyticsScreenState();
}

class _UserListingsAnalyticsScreenState extends ConsumerState<UserListingsAnalyticsScreen> {
  int _limit = 20;
  int _offset = 0;
  String? _statusFilter;
  String _orderBy = 'created_at';
  String _orderDir = 'desc';
  String _search = ''; // search by user email or name
  String? _selectedUserId;
  String _viewMode = 'view'; // 'provider' or 'view' - default to 'view' since RPC not deployed
  List<Map<String, dynamic>> _viewData = []; // Data from user_food_view
  bool _loadingView = false;

  @override
  void initState() {
    super.initState();
    // Fetch view data on init since RPC function may not be deployed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFromView();
    });
  }

  void _nextPage() => setState(() => _offset += _limit);
  void _prevPage() => setState(() => _offset = (_offset - _limit).clamp(0, _offset));

  /// Fetch data directly from the user_food_view (or fallback to food_listings)
  Future<void> _fetchFromView() async {
    setState(() => _loadingView = true);
    try {
      // Try user_food_view first
      try {
        final response = await Supabase.instance.client
            .from('user_food_view')
            .select()
            .order('created_at', ascending: _orderDir == 'asc');

        debugPrint('Response from user_food_view: $response');

        setState(() {
          _viewData = List<Map<String, dynamic>>.from(response as List);
          _loadingView = false;
        });
        return;
      } catch (viewError) {
        debugPrint('user_food_view not available: $viewError');
        // Fall back to direct query
      }

      // Fallback: Query food_listings directly and join with users manually
      final listings = await Supabase.instance.client
          .from('food_listings')
          .select('id, title, description, status, posted_by, created_at')
          .order('created_at', ascending: _orderDir == 'asc');

      debugPrint('Response from food_listings: $listings');

      // Transform to match expected format
      final List<Map<String, dynamic>> listingsData = 
          List<Map<String, dynamic>>.from(listings as List);

      // Fetch user details for each listing
      final enrichedData = <Map<String, dynamic>>[];
      for (final listing in listingsData) {
        try {
          final userId = listing['posted_by'];
          if (userId != null) {
            final user = await Supabase.instance.client
                .from('users')
                .select('id, email, first_name, last_name')
                .eq('id', userId)
                .maybeSingle();

            enrichedData.add({
              'food_listing_id': listing['id'],
              'food_name': listing['title'],
              'description': listing['description'],
              'status': listing['status'],
              'created_at': listing['created_at'],
              'user_id': userId,
              'user_name': user != null 
                  ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()
                  : 'Unknown User',
              'user_email': user?['email'],
            });
          }
        } catch (userError) {
          debugPrint('Error fetching user for listing: $userError');
          // Add listing without user info
          enrichedData.add({
            'food_listing_id': listing['id'],
            'food_name': listing['title'],
            'description': listing['description'],
            'status': listing['status'],
            'created_at': listing['created_at'],
            'user_name': 'Unknown User',
          });
        }
      }

      setState(() {
        _viewData = enrichedData;
        _loadingView = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _loadingView = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load listings. Please check database setup.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchFromView,
          ),
        ),
      );
    }
  }

  /// Call the stored function for a specific user (mainly for diagnostic / direct call demo)
  Future<void> _callStoredProcedure(String userId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'get_user_food_listings',
        params: {'p_posted_by': userId},
      );

      debugPrint('RPC response: $response');

      if (response == null) {
        throw Exception('RPC returned null. Function might not exist or is misconfigured.');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stored function executed for user'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error calling stored function: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Function error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = UserListingQuery(
      postedBy: _selectedUserId,
      status: _statusFilter,
      limit: _limit,
      offset: _offset,
      orderBy: _orderBy,
      orderDir: _orderDir,
    );

    final listingsAsync = ref.watch(userFoodListingsProvider(query));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        title: Text('User Listings Analytics', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            tooltip: 'Toggle Data Source',
            icon: Icon(_viewMode == 'view' ? Icons.functions : Icons.table_view, color: Colors.black),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'view' ? 'provider' : 'view';
              });
              if (_viewMode == 'view') _fetchFromView();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              if (_viewMode == 'view') {
                _fetchFromView();
              } else {
                final _ = ref.refresh(userFoodListingsProvider(query));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Data source indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.amber[50],
            child: Row(
              children: [
                Icon(
                  _viewMode == 'view' ? Icons.table_view : Icons.functions,
                  size: 16,
                  color: Colors.amber[900],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _viewMode == 'view' 
                        ? 'Data Source: SQL VIEW (user_food_view) - Direct table query'
                        : 'Data Source: SQL FUNCTION (get_user_food_listings) - Note: Function must be deployed to Supabase',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by user name or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    onSubmitted: (v) => setState(() { _search = v.trim(); _offset = 0; }),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _statusFilter,
                  hint: Text('Status'),
                  items: <String?>[null, 'available', 'removed', 'claimed', 'completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s ?? 'All')))
                      .toList(),
                  onChanged: (v) => setState(() { _statusFilter = v; _offset = 0; }),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() { _selectedUserId = null; _offset = 0; _search = ''; }),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
                  child: Text('Reset', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
          // Main content based on mode
          Expanded(
            child: _viewMode == 'view'
                ? _buildViewData()
                : _buildProviderData(listingsAsync),
          ),
          // Pagination controls
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Text('Rows $_offset - ${_offset + _limit}', style: GoogleFonts.poppins(fontSize: 12)),
                const Spacer(),
                IconButton(
                  tooltip: 'Previous Page',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _offset == 0 ? null : _prevPage,
                ),
                IconButton(
                  tooltip: 'Next Page',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    if (_viewMode == 'view') {
                      if (_viewData.length >= _offset + _limit) _nextPage();
                    } else {
                      _nextPage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewData() {
    if (_loadingView) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _viewData.where((r) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      final userName = (r['user_name'] ?? '').toString().toLowerCase();
      return userName.contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_view, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No results from view', style: GoogleFonts.poppins(color: Colors.grey[600])),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchFromView,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
            ),
          ],
        ),
      );
    }

    final page = filtered.skip(_offset).take(_limit).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: page.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _buildListingCard(page[i], isFromView: true),
    );
  }

  Widget _buildProviderData(AsyncValue<List<Map<String, dynamic>>> listingsAsync) {
    return listingsAsync.when(
      data: (rows) {
        final filtered = rows.where((r) {
          if (_search.isEmpty) return true;
          final q = _search.toLowerCase();
          final email = (r['user_email'] ?? '').toString().toLowerCase();
          final fn = (r['user_first_name'] ?? '').toString().toLowerCase();
          final ln = (r['user_last_name'] ?? '').toString().toLowerCase();
          return email.contains(q) || fn.contains(q) || ln.contains(q);
        }).toList();

        if (filtered.isEmpty) {
          return Center(child: Text('No results', style: GoogleFonts.poppins()));
        }

        final page = filtered.skip(_offset).take(_limit).toList();

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: page.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _buildListingCard(page[i], isFromView: false),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed: $e', style: GoogleFonts.poppins())),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> r, {required bool isFromView}) {
    final foodName = (r['food_name'] ?? '').toString();
    final description = isFromView
        ? (r['description'] ?? '').toString()
        : (r['food_description'] ?? '').toString();
    final userName = isFromView
        ? (r['user_name'] ?? '').toString()
        : '${r['user_first_name'] ?? ''} ${r['user_last_name'] ?? ''}'.trim();
    final userEmail = isFromView ? '' : (r['user_email'] ?? '').toString();
    final status = (r['status'] ?? 'available').toString();
    final createdAt = (r['created_at'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Row(
          children: [
            Expanded(
              child: Text(foodName, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'removed' ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: (status == 'removed' ? Colors.red[200] : Colors.green[200])!),
              ),
              child: Text(
                status.isEmpty ? 'unknown' : status,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: status == 'removed' ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins()),
            const SizedBox(height: 6),
            Text(
              'By: $userName${userEmail.isNotEmpty ? ' — $userEmail' : ''}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(createdAt, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        onTap: isFromView && r['user_id'] != null
            ? () => _callStoredProcedure(r['user_id'].toString())
            : null,
      ),
    );
  }
}
