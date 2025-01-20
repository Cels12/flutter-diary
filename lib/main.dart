import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home.dart';

void main() async{
  //supabase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://yrsfburtuqqaufbilgjg.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlyc2ZidXJ0dXFxYXVmYmlsZ2pnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcwMDA4MjAsImV4cCI6MjA1MjU3NjgyMH0.pA-kM2MZTyXMJimD5P-qtezH6K8Uhpe0rEeaYnp8kQw'
  );
  //run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}