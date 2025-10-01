import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewListingsScreen extends StatefulWidget {
  const ReviewListingsScreen({super.key});

  @override
  State<ReviewListingsScreen> createState() => _ReviewListingsScreenState();
}

class _ReviewListingsScreenState extends State<ReviewListingsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  String _query = '';
  bool _showRemoved = false; // false => show active; true => show removed

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final query = supabase
          .from('listings')
          .select('id, title, description, status, created_at, image_url, donor_name');
      final rows = _showRemoved
          ? await query.eq('status', 'removed').order('created_at', ascending: false)
          : await query.neq('status', 'removed').order('created_at', ascending: false);
      setState(() {
        _items = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    }
  }

  Future<void> _removeListing(String id) async {
    String? reason;
    await showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Remove listing'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)'
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () { reason = controller.text.trim(); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white),
              child: const Text('Remove'),
            )
          ],
        );
      },
    );
    try {
      await Supabase.instance.client
          .from('listings')
          .update({'status': 'removed', if (reason != null && reason!.isNotEmpty) 'removal_reason': reason})
          .eq('id', id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Remove failed: $e')));
    }
  }

  Future<void> _restoreListing(String id) async {
    try {
      await Supabase.instance.client
          .from('listings')
          .update({'status': 'active'})
          .eq('id', id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((it) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (it['title'] ?? '').toString().toLowerCase().contains(q) ||
          (it['donor_name'] ?? '').toString().toLowerCase().contains(q) ||
          (it['description'] ?? '').toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        elevation: 0,
        title: Text('Moderate Listings', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _load,
          )
        ],
      ),
      body: Column(
        children: [
          // Filters + Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Active'),
                  selected: !_showRemoved,
                  onSelected: (v) {
                    setState(() => _showRemoved = !v);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Removed'),
                  selected: _showRemoved,
                  onSelected: (v) {
                    setState(() => _showRemoved = v);
                    _load();
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search title, donor, description',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _showRemoved ? 'No removed listings.' : 'No listings found.',
                          style: GoogleFonts.poppins(),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (_, i) {
                          final it = filtered[i];
                          final isRemoved = (it['status'] ?? '') == 'removed';
                          return Container(
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: (() {
                                        final img = (it['image_url'] ?? '').toString();
                                        return img.isNotEmpty;
                                      })()
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network((it['image_url'] ?? '').toString(), fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.fastfood, color: Colors.black54),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              (it['title'] ?? 'Listing').toString(),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isRemoved ? Colors.red[50] : Colors.green[50],
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(color: (isRemoved ? Colors.red[200] : Colors.green[200])!),
                                            ),
                                            child: Text(
                                              isRemoved ? 'Removed' : 'Active',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: isRemoved ? Colors.red[700] : Colors.green[700],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (it['description'] ?? '').toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 16, color: Colors.grey[700]),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              (it['donor_name'] ?? 'Unknown donor').toString(),
                                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    if (!isRemoved)
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Remove'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red[700],
                                          side: BorderSide(color: Colors.red[300]!),
                                        ),
                                        onPressed: () => _removeListing(it['id'].toString()),
                                      )
                                    else
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.restore),
                                        label: const Text('Restore'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[500],
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => _restoreListing(it['id'].toString()),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: filtered.length,
                      ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
    );
  }
}
