import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_sphere/main/authenticationPage.dart';
import 'package:health_sphere/main/landingPage.dart';
import 'Orbit/Notes/NotesScreen.dart';
import 'main/BottomNavigation/PageNavigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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

