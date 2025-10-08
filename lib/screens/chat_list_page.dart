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

      // First try with a simple query to see if we have any messages
      final simpleResponse = await _supabase
          .from('chat_messages')
          .select('sender_id, receiver_id, message_text, timestamp')
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('timestamp', ascending: false);

      debugPrint('Simple query result: $simpleResponse');

      // Try to fetch conversations with user information
      final response = await _supabase
          .from('chat_messages')
          .select(
            'sender_id, receiver_id, message_text, timestamp, sender:users!chat_messages_sender_id_fkey(first_name, last_name), receiver:users!chat_messages_receiver_id_fkey(first_name, last_name)',
          )
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('timestamp', ascending: false);

      debugPrint('Full query result: $response');

      // Group messages by conversation partner
      Map<String, Map<String, dynamic>> conversationsMap = {};
      
      for (var data in response as List<dynamic>) {
        final isSender = data['sender_id'] == currentUserId;
        final otherUserId = isSender ? data['receiver_id'] : data['sender_id'];
        
        // Build user name from first_name and last_name
        String otherUserName = 'Unknown User';
        if (isSender && data['receiver'] != null) {
          final receiver = data['receiver'];
          final firstName = receiver['first_name'] ?? '';
          final lastName = receiver['last_name'] ?? '';
          otherUserName = '$firstName $lastName'.trim();
          if (otherUserName.isEmpty) otherUserName = 'Unknown User';
        } else if (!isSender && data['sender'] != null) {
          final sender = data['sender'];
          final firstName = sender['first_name'] ?? '';
          final lastName = sender['last_name'] ?? '';
          otherUserName = '$firstName $lastName'.trim();
          if (otherUserName.isEmpty) otherUserName = 'Unknown User';
        }
        
        final messageText = data['message_text'] ?? '';
        final timestamp = DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now();
        
        debugPrint('Processing message: sender=$isSender, otherUserId=$otherUserId, otherUserName=$otherUserName, message=$messageText');
        
        // Use other user ID as key to group conversations
        if (!conversationsMap.containsKey(otherUserId) || 
            conversationsMap[otherUserId]!['timestamp'].isBefore(timestamp)) {
          conversationsMap[otherUserId] = {
            'other_user_id': otherUserId,
            'other_user_name': otherUserName,
            'last_message': messageText,
            'last_message_time': timestamp,
            'timestamp': timestamp,
          };
        }
      }
      
      debugPrint('Conversations map: $conversationsMap');
      
      // Convert map to list and sort by timestamp
      final conversationsList = conversationsMap.values.toList();
      conversationsList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      debugPrint('Final conversations list: $conversationsList');

      setState(() {
        _conversations = conversationsList;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading conversations: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Fallback: Load messages without user join and fetch user names separately
      try {
        final currentUserIdFallback = _supabase.auth.currentUser?.id;
        if (currentUserIdFallback == null) {
          setState(() => _isLoading = false);
          return;
        }
        
        debugPrint('Attempting fallback query...');
        final fallbackResponse = await _supabase
            .from('chat_messages')
            .select('sender_id, receiver_id, message_text, timestamp')
            .or('sender_id.eq.$currentUserIdFallback,receiver_id.eq.$currentUserIdFallback')
            .order('timestamp', ascending: false);
        
        debugPrint('Fallback query result: $fallbackResponse');
        
        // Group messages by conversation partner
        Map<String, Map<String, dynamic>> conversationsMap = {};
        
        for (var data in fallbackResponse as List<dynamic>) {
          final isSender = data['sender_id'] == currentUserIdFallback;
          final otherUserId = isSender ? data['receiver_id'] : data['sender_id'];
          final messageText = data['message_text'] ?? '';
          final timestamp = DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now();
          
          // Use other user ID as key to group conversations
          if (!conversationsMap.containsKey(otherUserId) || 
              conversationsMap[otherUserId]!['timestamp'].isBefore(timestamp)) {
            conversationsMap[otherUserId] = {
              'other_user_id': otherUserId,
              'other_user_name': 'Loading...', // Placeholder
              'last_message': messageText,
              'last_message_time': timestamp,
              'timestamp': timestamp,
            };
          }
        }
        
        // Fetch usernames for each conversation partner
        for (String userId in conversationsMap.keys) {
          try {
            final userResponse = await _supabase
                .from('users')
                .select('first_name, last_name, email')
                .eq('id', userId)
                .maybeSingle();
            
            if (userResponse != null) {
              final firstName = userResponse['first_name'] ?? '';
              final lastName = userResponse['last_name'] ?? '';
              String userName = '$firstName $lastName'.trim();
              if (userName.isEmpty) {
                userName = userResponse['email']?.toString().split('@')[0] ?? 'User';
              }
              conversationsMap[userId]!['other_user_name'] = userName;
            }
          } catch (e) {
            debugPrint('Error fetching user info for $userId: $e');
            // Keep the placeholder name
          }
        }
        
        // Convert map to list and sort by timestamp
        final conversationsList = conversationsMap.values.toList();
        conversationsList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {
          _conversations = conversationsList;
          _isLoading = false;
        });
        
      } catch (fallbackError) {
        debugPrint('Fallback query also failed: $fallbackError');
        setState(() => _isLoading = false);
      }
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
              color: Colors.amber[700],
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
                  onPressed: _showSearchDialog,
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
            final name = conv['other_user_name']?.toString().toLowerCase() ?? '';
            final email = conv['other_user_email']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || email.contains(query);
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
    final otherUserName = conversation['other_user_name']?.toString() ?? 'Unknown User';

    final lastMessage = conversation['last_message']?.toString() ?? '';
    final lastMessageTime = conversation['last_message_time'] is DateTime 
        ? conversation['last_message_time'] as DateTime
        : (conversation['last_message_time'] != null 
            ? DateTime.parse(conversation['last_message_time'].toString())
            : DateTime.now());
    final unreadCount = conversation['unread_count'] ?? 0;
    final listingTitle = conversation['listing_title']?.toString();

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
          child: Text(
            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Conversations', style: GoogleFonts.poppins()),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name or email...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
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
