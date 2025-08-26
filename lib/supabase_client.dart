import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://lgljnpncfdlaqxyscdxk.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnbGpucG5jZmRsYXF4eXNjZHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNDI5NTksImV4cCI6MjA3MDYxODk1OX0.5DAOluEr3wkRg9qgZqWTwbQSoVocKc7IoMpJcfqvX7E';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}