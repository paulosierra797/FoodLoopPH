import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      senderId: 'other',
      senderName: 'John Doe',
      message: 'Hi! Is the pizza still available?',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      avatar: 'https://i.imgur.com/3ZQ3Z5F.png',
      isRead: true,
    ),
    ChatMessage(
      id: '2',
      senderId: 'me',
      senderName: 'You',
      message: 'Yes, it\'s still available! Would you like to claim it?',
      timestamp: DateTime.now().subtract(Duration(minutes: 25)),
      avatar: '',
      isRead: true,
    ),
    ChatMessage(
      id: '3',
      senderId: 'other',
      senderName: 'John Doe',
      message: 'Great! What time can I pick it up?',
      timestamp: DateTime.now().subtract(Duration(minutes: 20)),
      avatar: 'https://i.imgur.com/3ZQ3Z5F.png',
      isRead: true,
    ),
    ChatMessage(
      id: '4',
      senderId: 'me',
      senderName: 'You',
      message:
          'You can pick it up anytime between 2-6 PM today. I\'ll be at the location mentioned in the post.',
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      avatar: '',
      isRead: true,
    ),
    ChatMessage(
      id: '5',
      senderId: 'other',
      senderName: 'John Doe',
      message: 'Perfect! I\'ll be there around 3 PM. Thank you so much! 🙏',
      timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      avatar: 'https://i.imgur.com/3ZQ3Z5F.png',
      isRead: false,
    ),
  ];

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
              backgroundImage: NetworkImage('https://i.imgur.com/3ZQ3Z5F.png'),
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Online',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
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
            child: ListView.builder(
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

  Widget _buildMessage(ChatMessage message) {
    bool isMe = message.senderId == 'me';

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
              backgroundImage: message.avatar.isNotEmpty
                  ? NetworkImage(message.avatar)
                  : null,
              backgroundColor: Colors.grey[300],
              child: message.avatar.isEmpty
                  ? Icon(Icons.person, size: 18, color: Colors.grey[600])
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
                      message.senderName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    ),
                  if (!isMe) SizedBox(height: 4),
                  Text(
                    message.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? Colors.blue[300]
                              : Colors.white70,
                        ),
                      ],
                    ],
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
              child: Icon(Icons.person, size: 18, color: Colors.white),
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
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey[600]),
            onPressed: () {
              _showAttachmentOptions(context);
            },
          ),
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
              color: Colors.amber[600],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                _sendMessage();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'me',
            senderName: 'You',
            message: _messageController.text.trim(),
            timestamp: DateTime.now(),
            avatar: '',
            isRead: false,
          ),
        );
      });
      _messageController.clear();
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
              leading: Icon(Icons.info_outline),
              title: Text('View Profile', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Block User', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.green,
                  onTap: () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.red,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String avatar;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.avatar,
    required this.isRead,
  });
}
