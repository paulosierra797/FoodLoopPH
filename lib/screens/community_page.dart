import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_page.dart';
import '../widgets/notification_dropdown.dart';
import 'watchlist_page.dart';
import 'listings_page.dart';
import 'profile_page.dart';
import 'about_page.dart';
import 'change_password_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedCategory = 'All Categories';
  OverlayEntry? _notificationOverlayEntry;
  bool _showAllNotifications = true; // true for "All", false for "Unread"
  final GlobalKey _notificationKey = GlobalKey();

  // State-managed notifications list
  List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "icon": Icons.forum,
      "title": "New Community Post",
      "subtitle": "Someone posted in Zero Waste category",
      "time": "5 mins ago",
      "isNew": true,
    },
    {
      "id": 2,
      "icon": Icons.thumb_up,
      "title": "Post Liked",
      "subtitle": "Maria liked your food waste tip",
      "time": "30 mins ago",
      "isNew": true,
    },
    {
      "id": 3,
      "icon": Icons.comment,
      "title": "New Comment",
      "subtitle": "Someone commented on your post",
      "time": "2 hours ago",
      "isNew": false,
    },
    {
      "id": 4,
      "icon": Icons.star,
      "title": "Expert Badge Earned",
      "subtitle": "You earned the Expert badge!",
      "time": "1 day ago",
      "isNew": false,
    },
  ];

  // Notification management functions for NotificationDropdown
  void _markNotificationAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((notif) => notif["id"] == id);
      if (index != -1) {
        _notifications[index]["isNew"] = false;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification["isNew"] = false;
      }
    });
  }

  void _showNotificationOverlay() {
    if (_notificationOverlayEntry != null) return;
    final RenderBox renderBox = _notificationKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _notificationOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 180 + size.width,
        top: offset.dy + size.height + 8,
        width: 320,
        child: NotificationDropdown(
          notifications: _notifications,
          onMarkAllAsRead: _markAllAsRead,
          onMarkAsRead: (id) {
            _markNotificationAsRead(id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationPage(),
              ),
            );
            _hideNotificationOverlay();
          },
          iconKey: _notificationKey,
          showAll: _showAllNotifications,
          onToggleShowAll: (showAll) {
            setState(() {
              _showAllNotifications = showAll;
            });
          },
          onClose: _hideNotificationOverlay,
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_notificationOverlayEntry!);
  }

  void _hideNotificationOverlay() {
    _notificationOverlayEntry?.remove();
    _notificationOverlayEntry = null;
  }

  // Sample community posts data
  final List<Map<String, dynamic>> _posts = [
    {
      "id": 1,
      "user": "Avani",
      "category": "Zero Waste",
      "timeAgo": "4 hours ago",
      "badge": "Newbie",
      "content": "Hello! I have expired extra virgin olive oil in a glass bottle. Please share your non-food use ideas in the comments...kinda stumped",
      "comments": 10,
      "likes": 15,
      "isLiked": false,
    },
    {
      "id": 2,
      "user": "Chris",
      "category": "Recipes",
      "timeAgo": "10 hours ago",
      "badge": null,
      "content": "Would love to see some people's recipes what they have made from collections/donations and good budget ideas",
      "comments": 5,
      "likes": 23,
      "isLiked": false,
    },
    {
      "id": 3,
      "user": "Eugene",
      "category": "Zero Waste",
      "timeAgo": "12 hours ago",
      "badge": null,
      "content": "Tips for reducing food waste at home? I always end up throwing away vegetables that I forget about in the fridge...",
      "comments": 8,
      "likes": 31,
      "isLiked": true,
    },
    {
      "id": 4,
      "user": "Maria",
      "category": "Tips",
      "timeAgo": "1 day ago",
      "badge": "Expert",
      "content": "Just discovered that banana peels make excellent natural fertilizer! My plants are loving it 🌱",
      "comments": 12,
      "likes": 45,
      "isLiked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Community',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Builder(
                builder: (context) {
                  final unreadCount = _notifications.where((notif) => notif["isNew"] == true).length;
                  return Stack(
                    children: [
                      GestureDetector(
                        key: _notificationKey,
                        onTap: _showNotificationOverlay,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.notifications, color: Colors.grey[700], size: 24),
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Forum Header Section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forum',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    // Category Dropdown
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCategory,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    // View FAQs Button
                    GestureDetector(
                      onTap: () {
                        _showFAQs();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View FAQs',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.help_outline, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Posts Feed
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePost();
        },
        backgroundColor: Colors.amber[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              // User Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.blue[300],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post['user'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            post['category'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          post['timeAgo'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (post['badge'] != null) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: post['badge'] == 'Expert' ? Colors.green[100] : Colors.amber[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(post['badge'] == 'Expert' ? '⭐' : '👑', style: TextStyle(fontSize: 10)),
                                SizedBox(width: 4),
                                Text(
                                  post['badge'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: post['badge'] == 'Expert' ? Colors.green[700] : Colors.amber[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.bookmark_border, color: Colors.grey[400], size: 20),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Post Content
          Text(
            post['content'],
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Post Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _openComments(post),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      '${post['comments']} comments',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              GestureDetector(
                onTap: () => _toggleLike(post['id']),
                child: Row(
                  children: [
                    Icon(
                      post['isLiked'] == true ? Icons.favorite : Icons.favorite_border, 
                      size: 18, 
                      color: post['isLiked'] == true ? Colors.red : Colors.grey[600]
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${post['likes']} likes',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ...['All Categories', 'Zero Waste', 'Recipes', 'Tips', 'General'].map((category) => 
              ListTile(
                title: Text(category),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
                selected: _selectedCategory == category,
              )
            ).toList(),
          ],
        ),
      ),
    );
  }

  void _showFAQs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How do I post in the community?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Tap the + button to create a new post.\n'),
              Text('Q: What categories are available?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Zero Waste, Recipes, Tips, and General.\n'),
              Text('Q: How do I earn badges?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Badges are earned through community participation and helpful contributions.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreatePost() {
    final TextEditingController contentController = TextEditingController();
    String selectedCategory = 'Zero Waste';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Create New Post',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Zero Waste', 'Recipes', 'Tips', 'General']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'What\'s on your mind?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: 'Share your thoughts with the community...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  setState(() {
                    _posts.insert(0, {
                      "id": _posts.length + 1,
                      "user": "You",
                      "category": selectedCategory,
                      "timeAgo": "now",
                      "badge": null,
                      "content": contentController.text,
                      "comments": 0,
                      "likes": 0,
                      "isLiked": false,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Post created successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              child: Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openComments(Map<String, dynamic> post) {
    final TextEditingController commentController = TextEditingController();
    List<Map<String, dynamic>> comments = [
      {
        "user": "Sarah",
        "content": "Great post! Thanks for sharing.",
        "timeAgo": "2 hours ago",
        "likes": 3,
        "isLiked": false,
      },
      {
        "user": "Mike",
        "content": "I completely agree with this approach.",
        "timeAgo": "1 hour ago",
        "likes": 1,
        "isLiked": true,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Comments',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.blue[300], size: 20),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['user'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(comment['content']),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        comment['timeAgo'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          setBottomSheetState(() {
                                            comment['isLiked'] = !comment['isLiked'];
                                            comment['likes'] += comment['isLiked'] ? 1 : -1;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                                              size: 14,
                                              color: comment['isLiked'] ? Colors.red : Colors.grey[500],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${comment['likes']}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (commentController.text.isNotEmpty) {
                            setBottomSheetState(() {
                              comments.add({
                                "user": "You",
                                "content": commentController.text,
                                "timeAgo": "now",
                                "likes": 0,
                                "isLiked": false,
                              });
                              commentController.clear();
                            });
                            // Update post comment count
                            setState(() {
                              final postIndex = _posts.indexWhere((p) => p['id'] == post['id']);
                              if (postIndex != -1) {
                                _posts[postIndex]['comments']++;
                              }
                            });
                          }
                        },
                        icon: Icon(Icons.send, color: Colors.amber[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleLike(int postId) {
    setState(() {
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        post['isLiked'] = !post['isLiked'];
        post['likes'] += post['isLiked'] ? 1 : -1;
      }
    });
  }


  Widget _buildMenuItemWithIcon(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }


}
