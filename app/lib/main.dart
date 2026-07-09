import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/auth_session_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initializeIfConfigured();
  await AuthSessionService.instance.initializeSession();
  runApp(const TalkLogApp());
}
