import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin screen to view and manage community posts
/// Allows admin to view all community posts and remove inappropriate content
class ManageCommunityScreen extends StatefulWidget {
  const ManageCommunityScreen({Key? key}) : super(key: key);

  @override
  State<ManageCommunityScreen> createState() => _ManageCommunityScreenState();
}

class _ManageCommunityScreenState extends State<ManageCommunityScreen> {
  int _limit = 20;
  int _offset = 0;
  String? _categoryFilter;
  String _orderDir = 'desc';
  String _search = ''; // search by content or author
  List<Map<String, dynamic>> _postsData = []; // Data from community_posts + users
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data from tables on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCommunityPosts();
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
      _categoryFilter = null;
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
    if (_categoryFilter != null) {
      activeFilters.add('Category: $_categoryFilter');
    }
    
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '${filteredData.length} posts found${activeFilters.isNotEmpty ? ' • ${activeFilters.join(' • ')}' : ''}',
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
    var filtered = _postsData.where((r) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      final authorName = (r['author_name'] ?? '').toString().toLowerCase();
      final content = (r['content'] ?? '').toString().toLowerCase();
      final category = (r['category'] ?? '').toString().toLowerCase();
      return authorName.contains(q) || content.contains(q) || category.contains(q);
    }).toList();

    // Apply category filter
    if (_categoryFilter != null) {
      filtered = filtered.where((r) => r['category'] == _categoryFilter).toList();
    }

    return filtered;
  }

  /// Fetch community posts data from tables (community_posts + users)
  Future<void> _fetchCommunityPosts() async {
    setState(() => _loading = true);
    try {
      // Query community_posts - try to get user data if users table exists, otherwise use author field
      final response = await Supabase.instance.client
          .from('community_posts')
          .select('id, user_id, category, content, images, timestamp, author, reactions')
          .order('timestamp', ascending: _orderDir == 'asc');

      debugPrint('Response from community_posts: $response');

      // Transform to consistent format
      final List<Map<String, dynamic>> enrichedData = [];
      for (final post in response as List<dynamic>) {
        // Use the author field directly from the community_posts table
        final authorName = (post['author'] ?? 'Unknown User').toString();
        
        // Calculate likes count from reactions JSONB
        int likesCount = 0;
        if (post['reactions'] != null) {
          try {
            final reactions = post['reactions'] as Map<String, dynamic>;
            likesCount = reactions['likes'] ?? 0;
          } catch (e) {
            // If reactions parsing fails, default to 0
            likesCount = 0;
          }
        }
        
        enrichedData.add({
          'post_id': post['id'],
          'user_id': post['user_id'],
          'author_name': authorName.isEmpty ? 'Unknown User' : authorName,
          'author_email': '', // No email available from current schema
          'category': post['category'] ?? 'General',
          'content': post['content'] ?? '',
          'images': post['images'], // This is text[] array
          'timestamp': post['timestamp'],
          'likes_count': likesCount,
        });
      }

      setState(() {
        _postsData = enrichedData;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching community posts: $e');
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load community posts: $e'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchCommunityPosts,
          ),
        ),
      );
    }
  }

  /// Delete a community post
  Future<void> _deletePost(String postId, String authorName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete this post by $authorName? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete the post from community_posts table
      await Supabase.instance.client
          .from('community_posts')
          .delete()
          .eq('id', postId);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post deleted successfully', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green[600],
        ),
      );

      // Refresh the posts list
      _fetchCommunityPosts();
    } catch (e) {
      debugPrint('Error deleting post: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete post: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        title: Text('Manage Community', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchCommunityPosts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Search and Filters
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
                            hintText: 'Search by author, content, or category...',
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
                          value: _categoryFilter,
                          hint: Text('All Categories', style: GoogleFonts.poppins(fontSize: 12)),
                          underline: SizedBox.shrink(),
                          isDense: true,
                          items: <String?>[null, 'General', 'Zero Waste', 'Food Safety', 'Recipes', 'Tips']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s ?? 'All Categories', style: GoogleFonts.poppins(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() { 
                            _categoryFilter = v; 
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
            if (_search.isNotEmpty || _categoryFilter != null)
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
              child: _buildPostsData(),
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

  Widget _buildPostsData() {
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
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              _search.isNotEmpty || _categoryFilter != null 
                  ? 'No posts match your search criteria' 
                  : 'No community posts found',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            if (_search.isNotEmpty || _categoryFilter != null)
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: Icon(Icons.clear_all),
                label: Text('Clear Filters'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              )
            else
              ElevatedButton.icon(
                onPressed: _fetchCommunityPosts,
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
      itemBuilder: (context, i) => _buildPostCard(page[i]),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> r) {
    final authorName = (r['author_name'] ?? '').toString();
    final category = (r['category'] ?? 'General').toString();
    final content = (r['content'] ?? '').toString();
    final timestamp = (r['timestamp'] ?? '').toString();
    final likesCount = (r['likes_count'] ?? 0);
    final images = r['images'] as List<dynamic>?;

    // Parse and format date
    String formattedDate = timestamp;
    try {
      final date = DateTime.parse(timestamp);
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Author and Category Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    authorName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getCategoryColor(category).withOpacity(0.3)),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(category),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Content
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800]),
            ),
            
            // Images indicator
            if (images != null && images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.image, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      '${images.length} image${images.length == 1 ? '' : 's'}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Footer with likes, date and actions
            Row(
              children: [
                Icon(Icons.favorite, size: 14, color: Colors.red[400]),
                SizedBox(width: 4),
                Text(
                  '$likesCount',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _deletePost(r['post_id'].toString(), authorName),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 28),
                  ),
                  icon: Icon(Icons.delete_outline, size: 16),
                  label: Text('Delete', style: GoogleFonts.poppins(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return Colors.grey[600]!;
      case 'zero waste':
        return Colors.green[700]!;
      case 'food safety':
        return Colors.red[700]!;
      case 'recipes':
        return Colors.orange[700]!;
      case 'tips':
        return Colors.purple[700]!;
      default:
        return Colors.grey[600]!;
    }
  }
}