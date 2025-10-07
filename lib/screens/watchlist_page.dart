import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/claimed_foods_provider.dart';
import 'chat_page.dart';

/// Watchlist page now shows foods the user has claimed (history of claims)
class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimedAsync = ref.watch(claimedFoodsProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Claimed Foods', style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange[600],
      ),
      body: claimedAsync.when(
        data: (rows) {
          if (user == null) {
            return _buildMessage(
              icon: Icons.lock_outline,
              title: 'Not Signed In',
              subtitle: 'Sign in to view foods you\'ve claimed.',
            );
          }
          if (rows.isEmpty) {
            return _buildMessage(
              icon: Icons.history_toggle_off,
              title: 'No Claimed Foods Yet',
              subtitle: 'Foods you claim will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Trigger a reload of claimed foods
              final _ = ref.refresh(claimedFoodsProvider);
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _ClaimedFoodCard(data: rows[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildMessage(
          icon: Icons.error_outline,
          title: 'Error Loading',
          subtitle: e.toString(),
        ),
      ),
    );
  }

  Widget _buildMessage({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimedFoodCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ClaimedFoodCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? 'Unknown').toString();
    final poster = (data['poster_name'] ?? 'Unknown Giver').toString();
    final claimedAtRaw = data['claimed_at'];
    DateTime? claimedAt;
    if (claimedAtRaw is String) {
      claimedAt = DateTime.tryParse(claimedAtRaw);
    } else if (claimedAtRaw is DateTime) {
      claimedAt = claimedAtRaw;
    }
    final dateStr = claimedAt != null ? DateFormat('MMM d, y • h:mm a').format(claimedAt.toLocal()) : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.orange[100],
          child: Icon(Icons.fastfood, color: Colors.orange[700]),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: $poster',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
            if (dateStr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(dateStr, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Claimed',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green[700]),
          ),
        ),
        onTap: () => _showClaimedOptions(context, data),
      ),
    );
  }

  void _showClaimedOptions(BuildContext context, Map<String, dynamic> data) {
    final posterId = data['poster_id']?.toString();
    final posterName = (data['poster_name'] ?? 'User').toString();
    final listingId = data['food_listing_id']?.toString();
    final listingTitle = (data['title'] ?? '').toString();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final canMessage = posterId != null && posterId.isNotEmpty && posterId != currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text(
                  listingTitle.isNotEmpty ? listingTitle : 'Claimed Food',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Posted by: $posterName',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                if (canMessage)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      label: Text('Message Donor', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.pop(ctx); // close sheet
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              otherUserId: posterId,
                              otherUserName: posterName,
                              listingId: listingId,
                              listingTitle: listingTitle.isNotEmpty ? listingTitle : null,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      posterId == currentUserId ? 'You posted this item.' : 'Messaging unavailable.',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
