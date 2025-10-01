import 'package:supabase_flutter/supabase_flutter.dart';

class ArchiveService {
  static final ArchiveService _instance = ArchiveService._internal();
  factory ArchiveService() => _instance;
  ArchiveService._internal();

  Future<void> archiveUser(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      // Fetch user details from the users table
      final userResponse = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // Insert user details into the archive table
      await supabase.from('archive_users').insert(userResponse);

      // Delete user from the users table
      await supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      print('Error archiving user: $e');
      rethrow;
    }
  }
}