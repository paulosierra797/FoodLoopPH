import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    _supabase
        .channel('chat_list_updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            // Refresh conversations when new messages arrive
            _loadConversations();
          },
        )
        .subscribe();
  }

  Future<void> _loadConversations() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      debugPrint('Loading conversations for user: $currentUserId');

      // Use the proper SQL function to get conversations
      try {
        final response = await _supabase.rpc('get_user_conversations', params: {
          'input_user_id': currentUserId,
        });

        debugPrint('Conversations from SQL function: $response');

        // Always use SQL function result if it doesn't throw an error
        final List<Map<String, dynamic>> conversations =
            List<Map<String, dynamic>>.from(response ?? []);

        debugPrint(
            'Using SQL function results with ${conversations.length} conversations');
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
        return;
      } catch (e) {
        debugPrint('Error using SQL function: $e');
        setState(() {
          _conversations = [];
          _isLoading = false;
        });
        return;
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading conversations: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _conversations = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header section
          Container(
            padding: EdgeInsets.all(16),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Messages',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.black),
                      onPressed: _toggleSearch,
                    ),
                  ],
                ),
                // Search bar (show/hide based on search state)
                if (_isSearching)
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: _clearSearch,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.amber[600]!),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                    ? _buildEmptyState()
                    : _buildConversationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start sharing food and connect with your community!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    final filteredConversations = _searchQuery.isEmpty
        ? _conversations
        : _conversations.where((conv) {
            final name =
                conv['other_user_name']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return name.contains(query);
          }).toList();

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredConversations.length,
        itemBuilder: (context, index) {
          final conversation = filteredConversations[index];
          return _buildConversationTile(conversation);
        },
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final otherUserName =
        conversation['other_user_name']?.toString() ?? 'Unknown User';

    final lastMessage = conversation['last_message']?.toString() ?? '';
    final lastMessageTime = conversation['last_message_time'] is DateTime
        ? conversation['last_message_time'] as DateTime
        : (conversation['last_message_time'] != null
            ? DateTime.parse(conversation['last_message_time'].toString())
                .toLocal()
            : DateTime.now());
    final unreadCount = conversation['unread_count'] ?? 0;
    final listingTitle = conversation['listing_title']?.toString();

    // Show simplified tile when searching
    if (_isSearching && _searchQuery.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.amber[100],
            backgroundImage: conversation['other_user_profile_picture'] != null
                ? NetworkImage(conversation['other_user_profile_picture'])
                : null,
            child: conversation['other_user_profile_picture'] == null
                ? Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800],
                    ),
                  )
                : null,
          ),
          title: Text(
            otherUserName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.chat_bubble_outline,
            color: Colors.grey[400],
            size: 20,
          ),
          onTap: () => _openChat(conversation),
        ),
      );
    }

    // Show full tile when not searching
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.amber[100],
          backgroundImage: conversation['other_user_profile_picture'] != null
              ? NetworkImage(conversation['other_user_profile_picture'])
              : null,
          child: conversation['other_user_profile_picture'] == null
              ? Text(
                  otherUserName.isNotEmpty
                      ? otherUserName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[800],
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUserName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listingTitle != null) ...[
              Text(
                'About: $listingTitle',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],
            Text(
              lastMessage.isEmpty ? 'No messages yet' : lastMessage,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
        trailing: Text(
          _formatTime(lastMessageTime),
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        onTap: () => _openChat(conversation),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _openChat(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          otherUserId: conversation['other_user_id'] ?? '',
          otherUserName: conversation['other_user_name'] ?? 'Unknown User',
          listingId: conversation['listing_id'],
          listingTitle: conversation['listing_title'],
        ),
      ),
    ).then((_) => _loadConversations()); // Refresh when returning
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
