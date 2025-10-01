import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/user_food_listings_provider.dart';

class UserListingsAnalyticsScreen extends ConsumerStatefulWidget {
  const UserListingsAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListingsAnalyticsScreen> createState() => _UserListingsAnalyticsScreenState();
}

class _UserListingsAnalyticsScreenState extends ConsumerState<UserListingsAnalyticsScreen> {
  int _limit = 20;
  int _offset = 0;
  String? _statusFilter;
  String _orderBy = 'created_at';
  String _orderDir = 'desc';
  String _search = ''; // search by user email or name
  String? _selectedUserId;

  void _nextPage() => setState(() => _offset += _limit);
  void _prevPage() => setState(() => _offset = (_offset - _limit).clamp(0, _offset));

  @override
  Widget build(BuildContext context) {
    final query = UserListingQuery(
      postedBy: _selectedUserId,
      status: _statusFilter,
      limit: _limit,
      offset: _offset,
      orderBy: _orderBy,
      orderDir: _orderDir,
    );

  final listingsAsync = ref.watch(userFoodListingsProvider(query));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        title: Text('User Listings Analytics', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: Colors.black), onPressed: () => ref.refresh(userFoodListingsProvider(query))),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by user name or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    onSubmitted: (v) => setState(() { _search = v.trim(); _offset = 0; }),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _statusFilter,
                  hint: Text('Status'),
                  items: <String?>[null, 'available', 'removed', 'claimed', 'completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s ?? 'All')))
                      .toList(),
                  onChanged: (v) => setState(() { _statusFilter = v; _offset = 0; }),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() { _selectedUserId = null; _offset = 0; _search = ''; }),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
                  child: Text('Reset', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
          Expanded(
            child: listingsAsync.when(
              data: (rows) {
                // If search is used, do client-side filter on returned rows
                final filtered = rows.where((r) {
                  if (_search.isEmpty) return true;
                  final q = _search.toLowerCase();
                  final email = (r['user_email'] ?? '').toString().toLowerCase();
                  final fn = (r['user_first_name'] ?? '').toString().toLowerCase();
                  final ln = (r['user_last_name'] ?? '').toString().toLowerCase();
                  return email.contains(q) || fn.contains(q) || ln.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text('No results', style: GoogleFonts.poppins()));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    final status = (r['status'] ?? '').toString();
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text((r['food_name'] ?? '').toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((r['food_description'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins()),
                            const SizedBox(height: 6),
                            Text('By: ${r['user_first_name'] ?? ''} ${r['user_last_name'] ?? ''} — ${r['user_email'] ?? ''}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            Text((r['created_at'] ?? '').toString(), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.person_search_outlined),
                                  label: const Text('View user'),
                                  onPressed: () {
                                    setState(() { _selectedUserId = (r['user_id'] ?? '').toString(); _offset = 0; });
                                  },
                                ),
                                const SizedBox(width: 8),
                                if (status != 'removed')
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.visibility_off_outlined),
                                    label: const Text('Hide'),
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red[700], side: BorderSide(color: Colors.red[300]!)),
                                    onPressed: () => _updateStatus(context, r['listing_id'].toString(), 'removed'),
                                  )
                                else
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('Unhide'),
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700], side: BorderSide(color: Colors.green[300]!)),
                                    onPressed: () => _updateStatus(context, r['listing_id'].toString(), 'available'),
                                  ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  onPressed: () => _confirmDelete(context, r['listing_id'].toString()),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Failed: $e', style: GoogleFonts.poppins())),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                TextButton.icon(onPressed: _prevPage, icon: const Icon(Icons.chevron_left), label: Text('Prev')),
                const SizedBox(width: 8),
                Text('Page ${(_offset / _limit).floor() + 1}', style: GoogleFonts.poppins()),
                const SizedBox(width: 8),
                TextButton.icon(onPressed: _nextPage, icon: const Icon(Icons.chevron_right), label: Text('Next')),
                const Spacer(),
                DropdownButton<int>(
                  value: _limit,
                  items: [10, 20, 50, 100].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                  onChanged: (v) => setState(() { _limit = v!; _offset = 0; }),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
    );
  }

  Future<void> _updateStatus(BuildContext context, String listingId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('food_listings')
          .update({'status': newStatus})
          .eq('id', listingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Listing ${newStatus == 'removed' ? 'hidden' : 'updated'}')));
      // Force provider refresh
      final q = UserListingQuery(
        postedBy: _selectedUserId,
        status: _statusFilter,
        limit: _limit,
        offset: _offset,
        orderBy: _orderBy,
        orderDir: _orderDir,
      );
  final _ = ref.refresh(userFoodListingsProvider(q));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, String listingId) async {
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
          .eq('id', listingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted')));
      final q = UserListingQuery(
        postedBy: _selectedUserId,
        status: _statusFilter,
        limit: _limit,
        offset: _offset,
        orderBy: _orderBy,
        orderDir: _orderDir,
      );
  final _ = ref.refresh(userFoodListingsProvider(q));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }
}
