import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin screen to view and manage user food listings
/// Utilizes:
/// - user_food_view (SQL VIEW for joined user + food data)
/// - get_user_food_listings (Stored Function)
class UserListingsAnalyticsScreen extends StatefulWidget {
  const UserListingsAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<UserListingsAnalyticsScreen> createState() => _UserListingsAnalyticsScreenState();
}

class _UserListingsAnalyticsScreenState extends State<UserListingsAnalyticsScreen> {
  int _limit = 20;
  int _offset = 0;
  String? _statusFilter;
  String _orderDir = 'desc';
  String _search = ''; // search by user email or name
  List<Map<String, dynamic>> _listingsData = []; // Data from food_listings + users
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data from tables on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserListings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _nextPage() => setState(() => _offset += _limit);
  void _prevPage() => setState(() => _offset = (_offset - _limit).clamp(0, _offset));

  void _performSearch(String searchTerm) {
    setState(() {
      _search = searchTerm;
      _offset = 0; // Reset to first page when searching
    });
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _statusFilter = null;
      _offset = 0;
      _search = '';
    });
  }

  Widget _buildSearchSummary() {
    final filteredData = _getFilteredData();
    
    List<String> activeFilters = [];
    if (_search.isNotEmpty) {
      activeFilters.add('Search: "$_search"');
    }
    if (_statusFilter != null) {
      activeFilters.add('Status: $_statusFilter');
    }
    
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '${filteredData.length} listings found${activeFilters.isNotEmpty ? ' • ${activeFilters.join(' • ')}' : ''}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.amber[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredData() {
    // Apply search filter
    var filtered = _listingsData.where((r) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      final userName = (r['user_name'] ?? '').toString().toLowerCase();
      final userEmail = (r['user_email'] ?? '').toString().toLowerCase();
      final foodName = (r['food_name'] ?? '').toString().toLowerCase();
      return userName.contains(q) || userEmail.contains(q) || foodName.contains(q);
    }).toList();

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((r) => r['status'] == _statusFilter).toList();
    }

    return filtered;
  }

  /// Fetch user listings data from tables (food_listings + users)
  Future<void> _fetchUserListings() async {
    setState(() => _loading = true);
    try {
      // Query food_listings with user data in a single efficient query
      final response = await Supabase.instance.client
          .from('food_listings')
          .select('id, title, description, status, created_at, posted_by, users(first_name, last_name, email)')
          .order('created_at', ascending: _orderDir == 'asc');

      debugPrint('Response from food_listings: $response');

      // Transform to consistent format
      final List<Map<String, dynamic>> enrichedData = [];
      for (final listing in response as List<dynamic>) {
        final user = listing['users'];
        final userName = user != null 
            ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()
            : 'Unknown User';
        
        enrichedData.add({
          'food_listing_id': listing['id'],
          'food_name': listing['title'],
          'description': listing['description'],
          'status': listing['status'],
          'created_at': listing['created_at'],
          'user_id': listing['posted_by'],
          'user_name': userName.isEmpty ? 'Unknown User' : userName,
          'user_email': user?['email'] ?? '',
        });
      }

      setState(() {
        _listingsData = enrichedData;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user listings: $e');
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load listings: $e'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchUserListings,
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        title: Text('User Listings Analytics', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchUserListings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Search and Filters - Fixed height container
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search bar row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by user name, email, or food name...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                                    onPressed: () {
                                      _searchController.clear();
                                      _performSearch('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.amber[700]!),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            // Real-time search with debouncing effect
                            Future.delayed(Duration(milliseconds: 500), () {
                              if (_searchController.text == value) {
                                _performSearch(value);
                              }
                            });
                          },
                          onSubmitted: _performSearch,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _performSearch(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(0, 40),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, size: 16),
                            SizedBox(width: 4),
                            Text('Search', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Filters and reset row
                  Row(
                    children: [
                      Text('Filters:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String?>(
                          value: _statusFilter,
                          hint: Text('All Status', style: GoogleFonts.poppins(fontSize: 12)),
                          underline: SizedBox.shrink(),
                          isDense: true,
                          items: <String?>[null, 'available', 'claimed', 'removed']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s ?? 'All Status', style: GoogleFonts.poppins(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() { 
                            _statusFilter = v; 
                            _offset = 0; 
                          }),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _resetFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size(0, 32),
                        ),
                        icon: Icon(Icons.clear_all, size: 14),
                        label: Text('Reset', style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Search results summary
            if (_search.isNotEmpty || _statusFilter != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border(bottom: BorderSide(color: Colors.amber[200]!)),
                ),
                child: _buildSearchSummary(),
              ),
            
            // Main content - Takes remaining space
            Expanded(
              child: _buildListingsData(),
            ),
            
            // Pagination controls - Fixed at bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Showing ${_offset + 1}-${(_offset + _limit).clamp(0, _getFilteredData().length)} of ${_getFilteredData().length}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Previous Page',
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _offset == 0 ? null : _prevPage,
                        style: IconButton.styleFrom(
                          backgroundColor: _offset == 0 ? Colors.grey[100] : Colors.amber[100],
                          foregroundColor: _offset == 0 ? Colors.grey[400] : Colors.amber[700],
                          minimumSize: Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Page ${(_offset / _limit).floor() + 1}',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next Page',
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _getFilteredData().length <= _offset + _limit ? null : _nextPage,
                        style: IconButton.styleFrom(
                          backgroundColor: _getFilteredData().length <= _offset + _limit ? Colors.grey[100] : Colors.amber[100],
                          foregroundColor: _getFilteredData().length <= _offset + _limit ? Colors.grey[400] : Colors.amber[700],
                          minimumSize: Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsData() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Use centralized filtering logic
    final filteredData = _getFilteredData();

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              _search.isNotEmpty || _statusFilter != null 
                  ? 'No listings match your search criteria' 
                  : 'No listings found',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            if (_search.isNotEmpty || _statusFilter != null)
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: Icon(Icons.clear_all),
                label: Text('Clear Filters'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              )
            else
              ElevatedButton.icon(
                onPressed: _fetchUserListings,
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              ),
          ],
        ),
      );
    }

    // Apply pagination
    final page = filteredData.skip(_offset).take(_limit).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: page.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _buildListingCard(page[i]),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> r) {
    final foodName = (r['food_name'] ?? '').toString();
    final description = (r['description'] ?? '').toString();
    final userName = (r['user_name'] ?? '').toString();
    final userEmail = (r['user_email'] ?? '').toString();
    final status = (r['status'] ?? 'available').toString();
    final createdAt = (r['created_at'] ?? '').toString();

    // Parse and format date
    String formattedDate = createdAt;
    try {
      final date = DateTime.parse(createdAt);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      // Keep original if parsing fails
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Status Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    foodName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                  ),
                  child: Text(
                    status.isEmpty ? 'unknown' : status,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Description
            if (description.isNotEmpty)
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            
            const SizedBox(height: 6),
            
            // User info and date in one row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'By: $userName${userEmail.isNotEmpty ? ' • $userEmail' : ''}',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'removed':
        return Colors.red[700]!;
      case 'claimed':
        return Colors.orange[700]!;
      case 'available':
        return Colors.green[700]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
