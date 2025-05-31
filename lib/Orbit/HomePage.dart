import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;
    final iconSize = screenWidth * 0.06;
    final fontSizeSmall = screenWidth * 0.035;
    final fontSizeLarge = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        toolbarHeight: screenHeight * 0.09,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/landingPageImage.png'),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back! 👋",
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: fontSizeSmall)),
            Text(user?.displayName ?? "Buddy",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: fontSizeLarge)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white, size: iconSize),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white, size: iconSize),
            onPressed: () {
              FirebaseAuth.instance.signOut().whenComplete(() {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: padding * 0.75),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search for workout, notes and reminders",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white38, size: iconSize),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text("Today's Program",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05)),
            ],
          ),
        ),
      ),
    );
  }
}
