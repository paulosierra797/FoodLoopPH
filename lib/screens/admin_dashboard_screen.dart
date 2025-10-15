import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin/manage_users_screen.dart';
import 'admin/user_listings_analytics.dart';
import 'admin/manage_community_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = false;
  int? _totalUsers;
  int? _totalPosts;
  int? _totalCommunityPosts;
  List<Map<String, dynamic>> _recentListings = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _dashUpdateStatus(String id, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('food_listings')
          .update({'status': newStatus})
          .eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == 'removed' ? 'Listing hidden' : 'Listing updated')),
      );
      await _loadStats();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update listing: $e')));
    }
  }

  Future<void> _dashDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Supabase.instance.client
          .from('food_listings')
          .delete()
          .eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted')));
      await _loadStats();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete listing: $e')));
    }
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final supabase = Supabase.instance.client;
    int? users;
    int? posts;
    int? communityPosts;
    
    try {
      final userRows = await supabase.from('users').select('id');
      users = (userRows as List).length;
    } catch (_) {
      users = null;
    }
    
    try {
      final postRows = await supabase.from('food_listings').select('id');
      posts = (postRows as List).length;
    } catch (_) {
      posts = null;
    }
    
    try {
      final communityRows = await supabase.from('community_posts').select('id');
      communityPosts = (communityRows as List).length;
    } catch (_) {
      communityPosts = null;
    }
    
    try {
      final recent = await supabase
          .from('food_listings')
          .select('id, title, description, status, created_at')
          .order('created_at', ascending: false)
          .limit(5);
      _recentListings = List<Map<String, dynamic>>.from(recent);
    } catch (_) {
      _recentListings = [];
    }
    
    if (!mounted) return;
    setState(() {
      _totalUsers = users;
      _totalPosts = posts;
      _totalCommunityPosts = communityPosts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final amber = Colors.amber[700]!;
    final subtitle = 'Manage the users, listings and community in one place';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: amber,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: Text('Admin Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loading ? null : _loadStats,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out?'),
                  content: const Text('You will be returned to the landing screen.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (_) {}
                if (!mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFF7FAF7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24), // Add bottom padding to scroll view
            child: Column(
              children: [
                // Hero header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber[600]!, Colors.orange[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber[200]!.withOpacity(0.7),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome, Admin',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                            const SizedBox(height: 6),
                            Text(subtitle,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.95),
                                )),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),

                // KPI grid - using Row instead of GridView
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          label: 'Total Users',
                          value: _loading ? null : (_totalUsers?.toString() ?? '—'),
                          icon: Icons.people_alt_outlined,
                          color: Colors.teal[400]!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _KpiCard(
                          label: 'Food Posts',
                          value: _loading ? null : (_totalPosts?.toString() ?? '—'),
                          icon: Icons.fastfood_outlined,
                          color: Colors.green[400]!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _KpiCard(
                          label: 'Community',
                          value: _loading ? null : (_totalCommunityPosts?.toString() ?? '—'),
                          icon: Icons.forum_outlined,
                          color: Colors.blue[400]!,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickAction(
                        icon: Icons.manage_accounts_outlined,
                        label: 'Manage\nUsers',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                      ),
                      _QuickAction(
                        icon: Icons.analytics_outlined,
                        label: 'User\nListings',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListingsAnalyticsScreen())),
                      ),
                      _QuickAction(
                        icon: Icons.forum_outlined,
                        label: 'Manage\nCommunity',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCommunityScreen())),
                      ),
                    ],
                  ),
                ),



                // Recent Food Listings
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Recent Food Listings', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadStats,
                        tooltip: 'Refresh listings',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _recentListings.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text('No recent listings', style: GoogleFonts.poppins(color: Colors.grey[700])),
                        )
                      : Column(
                          children: _recentListings.map((it) {
                            final status = (it['status'] ?? '').toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text((it['title'] ?? 'Listing').toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: status == 'removed' ? Colors.red[50] : Colors.green[50],
                                                borderRadius: BorderRadius.circular(999),
                                                border: Border.all(color: (status == 'removed' ? Colors.red[200] : Colors.green[200])!),
                                              ),
                                              child: Text(status.isEmpty ? 'unknown' : status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: status == 'removed' ? Colors.red[700] : Colors.green[700])),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text((it['description'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.grey[800])),
                                        const SizedBox(height: 6),
                                        Text((it['created_at'] ?? '').toString(), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (status != 'removed')
                                    OutlinedButton(
                                      onPressed: () => _dashUpdateStatus(it['id'].toString(), 'removed'),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red[700], side: BorderSide(color: Colors.red[300]!)),
                                      child: const Text('Hide'),
                                    )
                                  else
                                    OutlinedButton(
                                      onPressed: () => _dashUpdateStatus(it['id'].toString(), 'available'),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700], side: BorderSide(color: Colors.green[300]!)),
                                      child: const Text('Unhide'),
                                    ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _dashDelete(it['id'].toString()),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 32), // Increased bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String? value; // null => loading shimmer
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          value == null
              ? Container(
                  height: 14,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Text(
                  value!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.amber[700], size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

