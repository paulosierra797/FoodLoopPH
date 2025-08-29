import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final String author;
  final String authorAvatar;
  final String category;
  final String content;
  final List<String>? imagePaths;
  final DateTime timestamp;
  final Map<String, int> reactions;
  final List<PostComment> comments;
  String? userReaction;

  CommunityPost({
    required this.id,
    required this.author,
    required this.authorAvatar,
    required this.category,
    required this.content,
    this.imagePaths,
    required this.timestamp,
    required this.reactions,
    required this.comments,
    this.userReaction,
  });
}

class CommunityPageNew extends StatefulWidget {
  const CommunityPageNew({super.key});

  @override
  _CommunityPageNewState createState() => _CommunityPageNewState();
}

class _CommunityPageNewState extends State<CommunityPageNew> {
  String selectedCategory = 'All';

  // Sample posts data with Facebook-style content
  List<CommunityPost> posts = [
    CommunityPost(
      id: '1',
      author: 'Carlos Santos',
      authorAvatar: '�‍💼',
      category: 'Zero Waste',
      content:
          'Creative ways to use vegetable scraps! 🌱\n\nI always end up with vegetable scraps and slightly wilted vegetables. Looking for creative recipes or preservation methods to reduce food waste!\n\n#ZeroWaste #FoodSafety #CommunityTips',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      reactions: {'👍': 15, '❤️': 8, '🌱': 12, '💡': 5},
      comments: [
        PostComment(
          id: '1',
          author: 'John Cruz',
          authorAvatar: '👨‍💼',
          content:
              'Great question! I usually make vegetable broth with my scraps. Just save them in the freezer until you have enough!',
          timestamp: DateTime.now().subtract(Duration(minutes: 20)),
          reactions: {'👍': 3, '❤️': 1},
        ),
        PostComment(
          id: '2',
          author: 'Anna Lee',
          authorAvatar: '👩‍🍳',
          content:
              'Try making veggie chips! Just dehydrate them in the oven at low temp. My kids love them!',
          timestamp: DateTime.now().subtract(Duration(minutes: 15)),
          reactions: {'👍': 2, '🔥': 1},
        ),
      ],
    ),
    CommunityPost(
      id: '2',
      author: 'John Cruz',
      authorAvatar: '👨‍💼',
      category: 'Food Safety',
      content:
          'Best practices for food sharing 🔒\n\nWhat are the most important food safety guidelines we should follow when donating or receiving food through community sharing? Let\'s discuss and keep our community safe! 🛡️',
      imagePaths: [
        'https://images.unsplash.com/photo-1556909114-3e5caf136de9?w=400'
      ],
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      reactions: {'👍': 23, '🔒': 10, '❤️': 6},
      comments: [
        PostComment(
          id: '3',
          author: 'Dr. Santos',
          authorAvatar: '👨‍⚕️',
          content:
              'Very important topic! Always check expiry dates, proper storage temperature, and avoid dairy/meat products unless you\'re 100% sure about the source.',
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          reactions: {'👍': 5, '💯': 2},
        ),
      ],
    ),
    CommunityPost(
      id: '3',
      author: 'Chef Miguel',
      authorAvatar: '👨‍🍳',
      category: 'Recipes',
      content:
          'Leftover rice transformed! 🍚✨\n\nTurned yesterday\'s plain rice into delicious fried rice with some leftover vegetables. Zero waste cooking at its finest! Who else loves transforming leftovers? Share your tips below! 👇',
      imagePaths: [
        'https://images.unsplash.com/photo-1563379091339-03246963d49a?w=400',
        'https://images.unsplash.com/photo-1512003867696-6d5ce6835040?w=400'
      ],
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      reactions: {'😍': 32, '🤤': 18, '👍': 25, '🔥': 12},
      comments: [
        PostComment(
          id: '4',
          author: 'Carlos Santos',
          authorAvatar: '�‍💼',
          content: 'Looks amazing! Recipe please? 😍 I have leftover rice too!',
          timestamp: DateTime.now().subtract(Duration(hours: 3)),
          reactions: {'👍': 8, '❤️': 3},
        ),
      ],
    ),
  ];

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
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildFacebookStylePost(posts[index]);
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
                PopupMenuButton(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('Edit Post')),
                    PopupMenuItem(child: Text('Delete Post')),
                    PopupMenuItem(child: Text('Hide Post')),
                  ],
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

          // Reaction Summary
          if (post.reactions.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Reaction Icons
                  ...post.reactions.entries.take(3).map(
                        (entry) => Container(
                          margin: EdgeInsets.only(right: 2),
                          child:
                              Text(entry.key, style: TextStyle(fontSize: 16)),
                        ),
                      ),
                  SizedBox(width: 6),
                  Text(
                    '${post.reactions.values.reduce((a, b) => a + b)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
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

          // Action Buttons with Hover Reactions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildReactionButton(post)),
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

  // Facebook-style reaction button with hover effect
  Widget _buildReactionButton(CommunityPost post) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            onEnter: (_) => _showReactionPicker(post),
            child: GestureDetector(
              onLongPress: () => _showReactionPicker(post),
              onTap: () => _handleReaction(post, '👍'),
              child: Row(
                children: [
                  Icon(
                    post.userReaction != null
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    size: 18,
                    color: post.userReaction != null
                        ? Colors.orange[600]
                        : Colors.grey[600],
                  ),
                  SizedBox(width: 6),
                  Text(
                    post.userReaction ?? 'Like',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: post.userReaction != null
                          ? Colors.orange[600]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostBottomSheet(),
    );
  }

  void _showReactionPicker(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['👍', '❤️', '😂', '😮', '😢', '😡']
                .map(
                  (emoji) => GestureDetector(
                    onTap: () {
                      _handleReaction(post, emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(emoji, style: TextStyle(fontSize: 20)),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _handleReaction(CommunityPost post, String reaction) {
    setState(() {
      if (post.userReaction == reaction) {
        post.userReaction = null;
        if (post.reactions[reaction] != null && post.reactions[reaction]! > 0) {
          post.reactions[reaction] = post.reactions[reaction]! - 1;
        }
      } else {
        if (post.userReaction != null) {
          if (post.reactions[post.userReaction!] != null &&
              post.reactions[post.userReaction!]! > 0) {
            post.reactions[post.userReaction!] =
                post.reactions[post.userReaction!]! - 1;
          }
        }
        post.userReaction = reaction;
        post.reactions[reaction] = (post.reactions[reaction] ?? 0) + 1;
      }
    });
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
                        setState(() {
                          post.comments.add(PostComment(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            author: 'You',
                            authorAvatar: '👤',
                            content: commentController.text,
                            timestamp: DateTime.now(),
                            reactions: {},
                          ));
                        });
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

  void _showAllComments(CommunityPost post) {
    _showCommentDialog(post);
  }
}

// Create Post Bottom Sheet
class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post created successfully!')),
                        );
                      }
                      Navigator.pop(context);
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
                        'You',
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
