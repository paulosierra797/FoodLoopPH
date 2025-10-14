import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? listingId;
  final String? listingTitle;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.listingId,
    this.listingTitle,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _otherUserProfileImage;
  String? _currentUserProfileImage;
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealtimeSubscription();
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      
      // Load other user's profile image
      final otherUserResponse = await _supabase
          .from('users')
          .select('profile_picture')
          .eq('id', widget.otherUserId)
          .single();

      // Load current user's profile image
      String? currentUserImage;
      if (currentUserId != null) {
        final currentUserResponse = await _supabase
            .from('users')
            .select('profile_picture')
            .eq('id', currentUserId)
            .single();
        currentUserImage = currentUserResponse['profile_picture']?.toString();
      }

      if (mounted) {
        setState(() {
          _otherUserProfileImage = otherUserResponse['profile_picture']?.toString();
          _currentUserProfileImage = currentUserImage;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile images: $e');
    }
  }

  @override
  void dispose() {
    // Notify ChatListPage to refresh conversations when returning
    Navigator.pop(context, true);
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await _supabase.rpc('get_conversation_messages', params: {
        'user_id': currentUserId,
        'other_user_id': widget.otherUserId,
        'listing_id_param': widget.listingId,
        'limit_count': 50,
        'offset_count': 0,
      });

      if (mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(response ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupRealtimeSubscription() {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    // Simplified realtime subscription without complex filters
    _supabase
        .channel('chat_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            // Check if this message is relevant to current conversation
            final newMessage = payload.newRecord;
            final senderId = newMessage['sender_id'];
            final receiverId = newMessage['receiver_id'];
            
            if ((senderId == currentUserId && receiverId == widget.otherUserId) ||
                (senderId == widget.otherUserId && receiverId == currentUserId)) {
              _loadMessages(); // Reload messages when new message arrives
            }
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.amber[100],
              backgroundImage: _otherUserProfileImage != null 
                  ? NetworkImage(_otherUserProfileImage!) 
                  : null,
              child: _otherUserProfileImage == null
                  ? Text(
                      widget.otherUserName.isNotEmpty 
                          ? widget.otherUserName[0].toUpperCase() 
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.listingTitle != null)
                    Text(
                      'About: ${widget.listingTitle}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.amber[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              _showChatOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessage(_messages[index]);
                        },
                      ),
          ),
          _buildMessageInput(),
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
            'Start the conversation!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final currentUserId = _supabase.auth.currentUser?.id;
    bool isMe = message['sender_id'] == currentUserId;
    
    final messageText = message['message_text']?.toString() ?? '';
    final senderName = message['sender_name']?.toString() ?? 'Unknown';
    final senderProfileImage = message['sender_profile_image']?.toString();
    final timestamp = message['timestamp'] != null 
        ? DateTime.parse(message['timestamp']) 
        : DateTime.now();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.amber[100],
              backgroundImage: senderProfileImage != null 
                  ? NetworkImage(senderProfileImage) 
                  : null,
              child: senderProfileImage == null
                  ? Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.amber[600] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      senderName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    ),
                  if (!isMe) SizedBox(height: 4),
                  Text(
                    messageText,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isMe ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.amber[600],
              backgroundImage: _currentUserProfileImage != null 
                  ? NetworkImage(_currentUserProfileImage!) 
                  : null,
              child: _currentUserProfileImage == null
                  ? Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                maxLines: null,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isSending ? Colors.grey : Colors.amber[600],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      debugPrint('Sending message with params: sender_id=$currentUserId, receiver_id=${widget.otherUserId}, message_text=$messageText, listing_id=${widget.listingId}');

      await _supabase.rpc('send_message', params: {
        'sender_id': currentUserId,
        'receiver_id': widget.otherUserId,
        'message_text': messageText,
        'listing_id_param': widget.listingId,
      });

      _messageController.clear();
      await _loadMessages(); // Reload messages to show the new one
      
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.amber[600]),
              title: Text('View Profile', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _showUserProfile(context);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserProfile(BuildContext context) async {
    try {
      // Fetch user details from database
      final response = await _supabase
          .from('users')
          .select('id, first_name, last_name, username, email, created_at, profile_picture')
          .eq('id', widget.otherUserId)
          .single();

      final userData = Map<String, dynamic>.from(response);
      _displayUserProfileDialog(context, userData);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _displayUserProfileDialog(BuildContext context, Map<String, dynamic> userData) {
    final firstName = userData['first_name']?.toString() ?? '';
    final lastName = userData['last_name']?.toString() ?? '';
    final username = userData['username']?.toString() ?? '';
    final email = userData['email']?.toString() ?? '';
    final profileImageUrl = userData['profile_picture']?.toString();
    final createdAt = userData['created_at'] != null 
        ? DateTime.parse(userData['created_at']) 
        : null;

    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty ? fullName : username;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with avatar
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.amber[100],
                        backgroundImage: profileImageUrl != null 
                            ? NetworkImage(profileImageUrl) 
                            : null,
                        child: profileImageUrl == null
                            ? Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              )
                            : null,
                      ),
                      SizedBox(height: 12),
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (username.isNotEmpty && username != displayName) ...[
                        SizedBox(height: 4),
                        Text(
                          '@$username',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // User details
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildProfileDetailRow(Icons.email, 'Email', email),
                      SizedBox(height: 16),
                      _buildProfileDetailRow(
                        Icons.calendar_today, 
                        'Member since', 
                        createdAt != null ? _formatDate(createdAt) : 'Unknown'
                      ),
                    ],
                  ),
                ),
                
                // Close button
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.amber[600],
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.amber[600]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.year}';
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


