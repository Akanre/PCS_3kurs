import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_notes_app/auth_gate.dart';

const supabaseUrl = 'https://qfwnodkkolwncpbttcgu.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmd25vZGtrb2x3bmNwYnR0Y2d1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2Mzg5ODYsImV4cCI6MjA3NzIxNDk4Nn0.xg7QFioYewu6-kAmJCDYT6hR63FFXkEGGv4YbgSmBfE';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Notes',
      theme: ThemeData(useMaterial3: true),
      home: AuthGate(),
    );
  }
}
