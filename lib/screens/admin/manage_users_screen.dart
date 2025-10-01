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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase
          .from('users')
          .select('*');

      // Client-side sort for stability: last_name, first_name, email
      final list = List<Map<String, dynamic>>.from(rows);
      list.sort((a, b) {
        int cmp(String? x, String? y) => (x ?? '').toLowerCase().compareTo((y ?? '').toLowerCase());
        final byLast = cmp(a['last_name'] as String?, b['last_name'] as String?);
        if (byLast != 0) return byLast;
        final byFirst = cmp(a['first_name'] as String?, b['first_name'] as String?);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  Future<void> _toggleSuspend(Map<String, dynamic> user) async {
    final id = user['id'];
    final current = (user['is_suspended'] ?? false) == true;
    try {
      await Supabase.instance.client
          .from('users')
          .update({'is_suspended': !current})
          .eq('id', id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<void> _toggleAdmin(Map<String, dynamic> user) async {
    final id = user['id'];
    final role = (user['role'] ?? '').toString().toLowerCase();
    final newRole = role == 'admin' ? 'user' : 'admin';
    try {
      await Supabase.instance.client
          .from('users')
          .update({'role': newRole})
          .eq('id', id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change role: $e')),
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
                      final name = '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
                      final role = (u['role'] ?? 'user').toString();
                      final suspended = (u['is_suspended'] ?? false) == true;
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isNotEmpty ? name : (u['username'] ?? 'Unknown').toString(),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: role.toLowerCase() == 'admin' ? Colors.orange[100] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role,
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: suspended ? 'Unsuspend' : 'Suspend',
                              onPressed: () => _toggleSuspend(u),
                              icon: Icon(
                                suspended ? Icons.lock_open : Icons.lock,
                                color: suspended ? Colors.green : Colors.red,
                              ),
                            ),
                            IconButton(
                              tooltip: role.toLowerCase() == 'admin' ? 'Make user' : 'Make admin',
                              onPressed: () => _toggleAdmin(u),
                              icon: Icon(Icons.manage_accounts, color: Colors.blue[400]),
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
