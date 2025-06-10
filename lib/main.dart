import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_sphere/main/authenticationPage.dart';
import 'package:health_sphere/main/landingPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Orbit/Notes/NotesScreen.dart';
import 'main/BottomNavigation/PageNavigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (for Auth)
  await Firebase.initializeApp();

  // Initialize Supabase (for Storage or optionally Auth/Database)
  await Supabase.initialize(
    url: 'https://rqjdhskmasbsomldkkxx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxamRoc2ttYXNic29tbGRra3h4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0OTQ3MjYsImV4cCI6MjA2NTA3MDcyNn0.h3IB3SsHSZzXwIA_K9aLI1Wusb9ajWLYGk1YshPs0qA',
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      routes: {
        '/landingPage': (context) => const LandingPage(),
        '/navigation': (context) => const PageNavigation(),
        '/login': (context) => AuthenticationPage(isReturningUser: true,),
        '/notes': (context) => const NotesScreen(),
      },
      debugShowCheckedModeBanner:false,
      home: FirebaseAuth.instance.currentUser != null
          ? PageNavigation()
          :  LandingPage(),
    );
  }
}

