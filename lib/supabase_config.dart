import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://mtzkzveiozjwyvkzlahp.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10emt6dmVpb3pqd3l2a3psYWhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4MTIxNzIsImV4cCI6MjA4MTM4ODE3Mn0.w1wVV07Qy6YmlSppmjobuTFi34geZJHtH_VSOtq9RHE';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
