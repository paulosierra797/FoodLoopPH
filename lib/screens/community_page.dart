import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_service_provider.dart';

// Comment model
class PostComment {
  final String id;
  final String author;
  final String authorAvatar;
  final String content;
  final DateTime timestamp;
  final Map<String, int> reactions;

  PostComment({
    required this.id,
    required this.author,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    required this.reactions,
  });
}

// Post model to store post data
class CommunityPost {
  final String id;
  final String userId; // Add user_id to identify post owner
  final String author;
  final String authorAvatar;
  final String category;
  final String content;
  final List<String>? imagePaths;
  final DateTime timestamp;
  int likesCount; // Simple likes count
  final List<PostComment> comments;
  bool isLikedByUser; // Whether current user liked this post

  CommunityPost({
    required this.id,
    required this.userId,
    required this.author,
    required this.authorAvatar,
    required this.category,
    required this.content,
    this.imagePaths,
    required this.timestamp,
    required this.likesCount,
    required this.comments,
    this.isLikedByUser = false,
  });
}

class CommunityPageNew extends ConsumerStatefulWidget {
  const CommunityPageNew({super.key});

  @override
  ConsumerState<CommunityPageNew> createState() => _CommunityPageNewState();
}

class _CommunityPageNewState extends ConsumerState<CommunityPageNew> {
  final SupabaseClient supabase = Supabase.instance.client;
  String selectedCategory = 'All';
  List<CommunityPost> posts = [];
  Map<String, String> userCache = {}; // Cache for user ID to name mapping

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Get user display name from cache or fetch from database
  Future<String> _getUserDisplayName(String userId) async {
    debugPrint('🔍 Getting display name for user ID: $userId');

    if (userCache.containsKey(userId)) {
      debugPrint('✅ Found in cache: ${userCache[userId]}');
      return userCache[userId]!;
    }

    try {
      debugPrint('📡 Fetching from database...');
      final response = await supabase
          .from('users')
          .select('first_name, last_name, username')
          .eq('id', userId)
          .maybeSingle();

      debugPrint('📋 Database response: $response');

      if (response != null) {
        final firstName = response['first_name'] ?? '';
        final lastName = response['last_name'] ?? '';
        final username = response['username'] ?? '';

        debugPrint(
            '👤 User data - First: $firstName, Last: $lastName, Username: $username');

        String displayName;
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          displayName = '$firstName $lastName'.trim();
        } else if (username.isNotEmpty) {
          displayName = username;
        } else {
          displayName = 'Unknown User';
        }

        debugPrint('✅ Final display name: $displayName');
        userCache[userId] = displayName;
        return displayName;
      }
    } catch (e) {
      debugPrint('❌ Error fetching user display name: $e');
    }

    debugPrint('⚠️ Returning Unknown User for ID: $userId');
    userCache[userId] = 'Unknown User';
    return 'Unknown User';
  }

  Future<void> _fetchPosts() async {
    try {
      final currentUser = supabase.auth.currentUser;
      
      final response = await supabase
          .from('community_posts')
          .select('*, comments(*)') // Fetch posts along with their comments
          .order('timestamp', ascending: false);

      // Process posts and fetch user names
      final List<CommunityPost> fetchedPosts = [];
      for (var data in response as List<dynamic>) {
        debugPrint('📝 Processing post data: $data');

        // Get author name for post - using user_id field from database
        String userId = data['user_id']?.toString() ?? '';
        debugPrint('👤 Post user_id: "$userId"');

        String postAuthorName = 'Unknown User';
        if (userId.isNotEmpty) {
          postAuthorName = await _getUserDisplayName(userId);
        } else {
          debugPrint('⚠️ Empty user_id for post: ${data['id']}');
        }

        // Process comments and get user names
        final List<PostComment> processedComments = [];
        for (var comment in data['comments'] as List<dynamic>) {
          String commentUserId = comment['user_id']?.toString() ?? '';
          String commentAuthorName = 'Unknown User';
          if (commentUserId.isNotEmpty) {
            commentAuthorName = await _getUserDisplayName(commentUserId);
          }
          processedComments.add(PostComment(
            id: comment['id'],
            author: commentAuthorName,
            authorAvatar: '👤',
            content: comment['content'],
            timestamp: DateTime.parse(comment['created_at']),
            reactions: {},
          ));
        }

        // Fetch likes count for this post
        final likesResponse = await supabase
            .from('post_likes')
            .select('user_id')
            .eq('post_id', data['id']);
        
        final likesCount = (likesResponse as List).length;
        
        // Check if current user liked this post
        bool isLikedByUser = false;
        if (currentUser != null) {
          isLikedByUser = (likesResponse as List).any(
            (like) => like['user_id'] == currentUser.id
          );
        }

        fetchedPosts.add(CommunityPost(
          id: data['id'],
          userId: userId, // Store the user_id for authorization checks
          author: postAuthorName,
          authorAvatar: data['author_avatar'] ?? '👤',
          category: data['category'],
          content: data['content'],
          imagePaths: (data['images'] as List<dynamic>?)?.cast<String>(),
          timestamp: DateTime.parse(data['timestamp']),
          likesCount: likesCount,
          comments: processedComments,
          isLikedByUser: isLikedByUser,
        ));
      }

      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _createPost(
      String content, String category, List<String> imagePaths) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('Error: No authenticated user found.');
        return;
      }

      await supabase.from('community_posts').insert({
        'user_id': user.id, // Use user_id to match database schema
        'author': await _getUserDisplayName(user.id), // Get actual user name
        'author_avatar': '👤',
        'category': category,
        'content': content,
        'images': imagePaths,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _fetchPosts();
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Future<void> _addComment(String postId, String content) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('Error: No authenticated user found.');
        return;
      }

      await supabase.from('comments').insert({
        'post_id': postId,
        'user_id': user.id, // Use the authenticated user ID
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });
      _fetchPosts(); // Refresh posts to include new comments
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // Check if the current user is the post author
  bool _isCurrentUserPost(CommunityPost post) {
    final user = supabase.auth.currentUser;
    return user != null && user.id == post.userId;
  }

  // Show edit post dialog
  void _showEditPostDialog(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditPostBottomSheet(
        post: post,
        onPostEdited: (content, category) {
          _editPost(post.id, content, category);
        },
      ),
    );
  }

  // Edit post in database
  Future<void> _editPost(String postId, String content, String category) async {
    try {
      await supabase.from('community_posts').update({
        'content': content,
        'category': category,
      }).eq('id', postId);
      _fetchPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error editing post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmDialog(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Post',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  // Delete post from database
  Future<void> _deletePost(String postId) async {
    try {
      await supabase.from('community_posts').delete().eq('id', postId);
      _fetchPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Filter posts based on selected category
  List<CommunityPost> _getFilteredPosts() {
    if (selectedCategory == 'All') {
      return posts;
    }
    return posts.where((post) => post.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header section with smaller sorting
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Community',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                // Create Post Button
                GestureDetector(
                  onTap: () => _showCreatePostDialog(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Post',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter Dropdown
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Filter by: ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.orange[600]),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      items: [
                        'All',
                        'Zero Waste',
                        'Food Safety',
                        'Recipes',
                        'General',
                        'Tips'
                      ].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newCategory) {
                        setState(() {
                          selectedCategory = newCategory ?? 'All';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // "What's on your mind?" Create Post Section
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange[100],
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCreatePostDialog(),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        "What's on your mind?",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.photo_library, color: Colors.orange[600]),
                  onPressed: () => _showCreatePostDialog(),
                ),
              ],
            ),
          ),

          // Posts List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: _getFilteredPosts().length,
              itemBuilder: (context, index) {
                return _buildFacebookStylePost(_getFilteredPosts()[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Facebook-style post widget
  Widget _buildFacebookStylePost(CommunityPost post) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange[100],
                  child:
                      Text(post.authorAvatar, style: TextStyle(fontSize: 16)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _formatTimeAgo(post.timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.public, size: 12, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.category,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Only show menu if current user is the post author
                if (_isCurrentUserPost(post))
                  PopupMenuButton(
                    icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Text('Edit Post'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Post', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPostDialog(post);
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(post);
                      }
                    },
                  ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),

          // Post Images
          if (post.imagePaths != null && post.imagePaths!.isNotEmpty) ...[
            SizedBox(height: 12),
            SizedBox(
              height: post.imagePaths!.length == 1 ? 200 : 150,
              child: post.imagePaths!.length == 1
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imagePaths![0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.image,
                                    color: Colors.grey[400], size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: post.imagePaths!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post.imagePaths![index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(Icons.image,
                                        color: Colors.grey[400], size: 30),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],

          SizedBox(height: 12),

          // Likes and Comments Summary
          if (post.likesCount > 0 || post.comments.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (post.likesCount > 0) ...[
                    Icon(Icons.thumb_up, size: 16, color: Colors.orange[600]),
                    SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  Spacer(),
                  if (post.comments.isNotEmpty)
                    Text(
                      '${post.comments.length} comments',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

          SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey[200]),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildLikeButton(post)),
                Expanded(child: _buildCommentButton(post)),
              ],
            ),
          ),

          // Comments Section
          if (post.comments.isNotEmpty) ...[
            Divider(height: 1, color: Colors.grey[200]),
            ...post.comments
                .take(2)
                .map((comment) => _buildCommentWidget(comment)),
            if (post.comments.length > 2)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () => _showAllComments(post),
                  child: Text(
                    'View ${post.comments.length - 2} more comments',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],

          // Add Comment Section
          Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child: Text('👤', style: TextStyle(fontSize: 12)),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCommentDialog(post),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Write a comment...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simple like button
  Widget _buildLikeButton(CommunityPost post) {
    return GestureDetector(
      onTap: () => _toggleLike(post),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              post.isLikedByUser ? Icons.thumb_up : Icons.thumb_up_outlined,
              size: 18,
              color: post.isLikedByUser ? Colors.orange[600] : Colors.grey[600],
            ),
            SizedBox(width: 6),
            Text(
              'Like',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: post.isLikedByUser ? Colors.orange[600] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(CommunityPost post) {
    return GestureDetector(
      onTap: () => _showCommentDialog(post),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[600]),
            SizedBox(width: 6),
            Text(
              'Comment',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentWidget(PostComment comment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[200],
            child: Text(comment.authorAvatar, style: TextStyle(fontSize: 12)),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    comment.content,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void _showCreatePostDialog() {
    final userService = ref.read(userServiceProvider);
    final currentUser = userService.currentUser;
    final userDisplayName = currentUser != null
        ? '${currentUser.firstName} ${currentUser.lastName}'.trim().isEmpty
            ? currentUser.username
            : '${currentUser.firstName} ${currentUser.lastName}'.trim()
        : 'User';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostBottomSheet(
        userName: userDisplayName,
        onPostCreated: (content, category, imagePaths) {
          _createPost(content, category, imagePaths);
        },
      ),
    );
  }

  void _showCommentDialog(CommunityPost post) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: post.comments.length,
                itemBuilder: (context, index) =>
                    _buildCommentWidget(post.comments[index]),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        _addComment(post.id, commentController.text);
                        commentController.clear();
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.send, color: Colors.orange[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toggle like/unlike with database persistence
  Future<void> _toggleLike(CommunityPost post) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('Error: No authenticated user found.');
      return;
    }

    // Optimistic UI update
    setState(() {
      if (post.isLikedByUser) {
        post.isLikedByUser = false;
        post.likesCount--;
      } else {
        post.isLikedByUser = true;
        post.likesCount++;
      }
    });

    try {
      if (post.isLikedByUser) {
        // Insert like into database
        await supabase.from('post_likes').insert({
          'post_id': post.id,
          'user_id': user.id,
        });
        debugPrint('✅ Like added for post ${post.id}');
      } else {
        // Remove like from database
        await supabase
            .from('post_likes')
            .delete()
            .eq('post_id', post.id)
            .eq('user_id', user.id);
        debugPrint('✅ Like removed for post ${post.id}');
      }
    } catch (e) {
      print('❌ Error toggling like: $e');
      // Revert UI update if database operation failed
      setState(() {
        if (post.isLikedByUser) {
          post.isLikedByUser = false;
          post.likesCount--;
        } else {
          post.isLikedByUser = true;
          post.likesCount++;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showAllComments(CommunityPost post) {
    _showCommentDialog(post);
  }
}

// Create Post Bottom Sheet
class CreatePostBottomSheet extends StatefulWidget {
  final Function(String content, String category, List<String> imagePaths)
      onPostCreated;
  final String userName;

  const CreatePostBottomSheet(
      {super.key, required this.onPostCreated, required this.userName});

  @override
  _CreatePostBottomSheetState createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  String selectedCategory = 'General';
  List<String> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Create Post',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_contentController.text.isNotEmpty) {
                        // Handle post creation
                        widget.onPostCreated(
                          _contentController.text,
                          selectedCategory,
                          selectedImages,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Post',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            // User Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange[100],
                    child: Text('👤', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        underline: SizedBox(),
                        items: [
                          'General',
                          'Zero Waste',
                          'Food Safety',
                          'Recipes',
                          'Tips'
                        ]
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Input
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),

                    // Image Upload Section
                    Row(
                      children: [
                        IconButton(
                          onPressed: _selectImage,
                          icon: Icon(Icons.photo_library,
                              color: Colors.orange[600]),
                        ),
                        IconButton(
                          onPressed: _selectImage,
                          icon:
                              Icon(Icons.camera_alt, color: Colors.orange[600]),
                        ),
                        if (selectedImages.isNotEmpty) ...[
                          SizedBox(width: 12),
                          Text(
                            '${selectedImages.length} photo(s) selected',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedImages.clear();
                              });
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage() {
    // Simulate image selection
    setState(() {
      selectedImages.add('dummy_image_path');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image selected! (Simulated)'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Edit Post Bottom Sheet
class EditPostBottomSheet extends StatefulWidget {
  final CommunityPost post;
  final Function(String content, String category) onPostEdited;

  const EditPostBottomSheet({
    super.key,
    required this.post,
    required this.onPostEdited,
  });

  @override
  _EditPostBottomSheetState createState() => _EditPostBottomSheetState();
}

class _EditPostBottomSheetState extends State<EditPostBottomSheet> {
  late TextEditingController _contentController;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    selectedCategory = widget.post.category;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Edit Post',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_contentController.text.isNotEmpty) {
                        widget.onPostEdited(
                          _contentController.text,
                          selectedCategory,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            // User Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange[100],
                    child: Text('👤', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        underline: SizedBox(),
                        items: [
                          'General',
                          'Zero Waste',
                          'Food Safety',
                          'Recipes',
                          'Tips'
                        ]
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Input
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
