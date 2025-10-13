import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];
  String _query = '';
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;

      // Load users based on archive filter
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
          supabase.from('users').select('*');

      if (_showArchived) {
        // Show only archived users (archived_at IS NOT NULL)
        query = query.not('archived_at', 'is', null);
        print('🔍 Loading ARCHIVED users (archived_at IS NOT NULL)');
      } else {
        // Show only active users (archived_at IS NULL)
        query = query.isFilter('archived_at', null);
        print('🔍 Loading ACTIVE users (archived_at IS NULL)');
      }

      final rows = await query;
      print(
          '📊 Loaded ${rows.length} users for filter: ${_showArchived ? "ARCHIVED" : "ACTIVE"}');

      // Client-side sort for stability: last_name, first_name, email
      final list = List<Map<String, dynamic>>.from(rows);
      list.sort((a, b) {
        int cmp(String? x, String? y) =>
            (x ?? '').toLowerCase().compareTo((y ?? '').toLowerCase());
        final byLast =
            cmp(a['last_name'] as String?, b['last_name'] as String?);
        if (byLast != 0) return byLast;
        final byFirst =
            cmp(a['first_name'] as String?, b['first_name'] as String?);
        if (byFirst != 0) return byFirst;
        return cmp(a['email'] as String?, b['email'] as String?);
      });

      setState(() {
        _users = list;
        _loading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e.message.contains('permission denied')
          ? 'Failed to load users: RLS/permissions denied. Ensure admin role can SELECT on users.'
          : 'Failed to load users: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  Future<void> _toggleArchive(Map<String, dynamic> user) async {
    final id = user['id'];
    final isArchived = user['archived_at'] != null;
    final userName =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final displayName =
        userName.isNotEmpty ? userName : (user['username'] ?? 'Unknown user');

    // 1) Ask for confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isArchived ? 'Restore User' : 'Archive User',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            isArchived
                ? 'Are you sure you want to restore "$displayName"? This will make their account active again.'
                : 'Are you sure you want to archive "$displayName"? This will disable their account and hide their content.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isArchived ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                isArchived ? 'Restore' : 'Archive',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final supabase = Supabase.instance.client;
      print('🔧 Attempting to ${isArchived ? 'restore' : 'archive'} user: $id');

      // Use the dedicated archive_user() SQL function instead of direct UPDATE
      // This function bypasses RLS restrictions and is designed for admin operations
      final result = await supabase.rpc('archive_user', params: {
        'user_id': id,
        'should_archive': !isArchived, // true to archive, false to restore
      });

      print('✅ Archive function result: $result');

      final success = result == true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? (isArchived
                    ? '✅ User "$displayName" has been restored'
                    : '🗃️ User "$displayName" has been archived')
                : 'Failed to ${isArchived ? 'restore' : 'archive'} user. Please check admin permissions.'),
            backgroundColor: success
                ? (isArchived ? Colors.green : Colors.orange)
                : Colors.red,
          ),
        );
      }

      // Reload the user list to reflect changes
      await _load();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      print('🚫 PostgrestException: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      print('🚫 General error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to ${isArchived ? 'restore' : 'archive'} user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (u['email'] ?? '').toString().toLowerCase().contains(q) ||
          (u['username'] ?? '').toString().toLowerCase().contains(q) ||
          (u['first_name'] ?? '').toString().toLowerCase().contains(q) ||
          (u['last_name'] ?? '').toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        elevation: 0,
        title: Text('Manage Users', style: GoogleFonts.poppins()),
        actions: [
          // Archive filter toggle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ChoiceChip(
              label: Text(
                _showArchived ? 'Archived' : 'Active',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _showArchived ? Colors.white : Colors.black,
                ),
              ),
              selected: _showArchived,
              onSelected: (selected) {
                setState(() => _showArchived = selected);
                _load();
              },
              selectedColor: Colors.red[600],
              backgroundColor: Colors.white,
              side: BorderSide(
                color: _showArchived ? Colors.red[600]! : Colors.grey[400]!,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _load,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by email, username, or name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No users found. If you expect data, check that:\n\n• Your public.users table has rows\n• RLS policies allow admin to SELECT',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (_, i) {
                          final u = filtered[i];
                          final name =
                              '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'
                                  .trim();
                          final role = (u['role'] ?? 'user').toString();
                          final suspended =
                              (u['is_suspended'] ?? false) == true;
                          final isArchived = u['archived_at'] != null;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.amber[100],
                                  child: Text(
                                    (u['username'] ?? 'U')
                                        .toString()
                                        .characters
                                        .first
                                        .toUpperCase(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isNotEmpty
                                            ? name
                                            : (u['username'] ?? 'Unknown')
                                                .toString(),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (u['email'] ?? '').toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  role.toLowerCase() == 'admin'
                                                      ? Colors.orange[100]
                                                      : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              role,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12),
                                            ),
                                          ),
                                          if (isArchived) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'ARCHIVED',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (suspended) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.yellow[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'SUSPENDED',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.orange[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: isArchived
                                      ? 'Restore user'
                                      : 'Archive user',
                                  onPressed: () => _toggleArchive(u),
                                  icon: Icon(
                                    isArchived
                                        ? Icons.unarchive
                                        : Icons.archive,
                                    color: isArchived
                                        ? Colors.green[600]
                                        : Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: filtered.length,
                      )),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
    );
  }
}
