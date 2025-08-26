import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final List<ChatContact> _contacts = [
    ChatContact(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Perfect! I\'ll be there around 3 PM. Thank you so much! 🙏',
      timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      unreadCount: 2,
      avatar: 'https://i.imgur.com/3ZQ3Z5F.png',
      isOnline: true,
    ),
    ChatContact(
      id: '2',
      name: 'Sarah Wilson',
      lastMessage: 'Is the chicken still available?',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      unreadCount: 1,
      avatar: 'https://i.imgur.com/jX0Xn5G.png',
      isOnline: false,
    ),
    ChatContact(
      id: '3',
      name: 'Mike Johnson',
      lastMessage: 'Thanks for the food! It was delicious.',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      unreadCount: 0,
      avatar: 'https://i.imgur.com/IDQK9tC.png',
      isOnline: true,
    ),
    ChatContact(
      id: '4',
      name: 'Emma Davis',
      lastMessage: 'When can I pick up the pizza?',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      unreadCount: 0,
      avatar: '',
      isOnline: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.amber[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Status Section
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount:
                  _contacts.where((contact) => contact.isOnline).length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddStoryCard();
                }
                final onlineContacts =
                    _contacts.where((contact) => contact.isOnline).toList();
                final contact = onlineContacts[index - 1];
                return _buildActiveUserCard(contact);
              },
            ),
          ),
          // Chat List
          Expanded(
            child: _contacts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      return _buildChatTile(_contacts[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog(context);
        },
        backgroundColor: Colors.amber[600],
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildAddStoryCard() {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Icon(Icons.add, color: Colors.grey[600], size: 24),
          ),
          SizedBox(height: 8),
          Text(
            'Your Story',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUserCard(ChatContact contact) {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: contact.avatar.isNotEmpty
                    ? NetworkImage(contact.avatar)
                    : null,
                backgroundColor: Colors.grey[300],
                child: contact.avatar.isEmpty
                    ? Icon(Icons.person, size: 28, color: Colors.grey[600])
                    : null,
              ),
              if (contact.isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            contact.name.split(' ')[0],
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatContact contact) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
                contact.avatar.isNotEmpty ? NetworkImage(contact.avatar) : null,
            backgroundColor: Colors.grey[300],
            child: contact.avatar.isEmpty
                ? Icon(Icons.person, size: 28, color: Colors.grey[600])
                : null,
          ),
          if (contact.isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              contact.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            _formatTime(contact.timestamp),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              contact.lastMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color:
                    contact.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight: contact.unreadCount > 0
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (contact.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                contact.unreadCount.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start sharing food and connect with your community!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
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
              leading: Icon(Icons.mark_chat_read),
              title: Text('Mark all as read', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archived chats', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Chat settings', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Start New Chat',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_search),
              title: Text('Find Users', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                // Implement user search
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text('Scan QR Code', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                // Implement QR scanner
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class ChatContact {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String avatar;
  final bool isOnline;

  ChatContact({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.avatar,
    required this.isOnline,
  });
}
