import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subscription_tracker/Auth_pages/login_page.dart';
import 'package:subscription_tracker/pages/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://clhooscrmjjxccebdxkm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNsaG9vc2NybWpqeGNjZWJkeGttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxNjEwNjcsImV4cCI6MjA3MjczNzA2N30.T9oIny5ihFhHWWCK1kPNluZKrdQpp_c15ugvDH48OjE',
  );
  runApp(MyApp());
}

final supabaseClient = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF2E3440),
          secondary: Color(0xFF5E81AC),
          surface: Color(0xFFF3F3F3),
          onSurface: Color(0xFF2E3440),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: AuthStateCheck(),
    );
  }
}

class AuthStateCheck extends StatelessWidget {
  const AuthStateCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Some Error Occurred");
        }

        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (session != null) {
          return MainPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
