import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePageViewer extends StatefulWidget {
  const ProfilePageViewer({super.key});

  @override
  State<ProfilePageViewer> createState() => _ProfilePageViewerState();
}

class _ProfilePageViewerState extends State<ProfilePageViewer> {

  final Color accentColor = const Color(0xFFB3FF4A);

  Future<Map<String, dynamic>?> fetchUserGoalData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('notes')
        .doc(uid)
        .collection('goal')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: width,
                color: accentColor,
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: height * 0.02),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: width * 0.08,
                      backgroundImage:
                      const AssetImage('assets/user.jpg'), // Replace if needed
                    ),
                    SizedBox(width: width * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${FirebaseAuth.instance.currentUser?.displayName ?? ''}",
                          style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          "${FirebaseAuth.instance.currentUser?.email ?? ''}",
                          style: TextStyle(
                              fontSize: width * 0.035, color: Colors.black87),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.settings, color: Colors.black, size: width * 0.07),
                      onPressed: () {},
                    )
                  ],
                ),
              ),

              // Follower stats
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: height * 0.02),
                child: Row(
                  children: [
                    Text("1.5K Followers",
                        style: TextStyle(
                            color: Colors.white, fontSize: width * 0.04)),
                    SizedBox(width: width * 0.02),
                    Text("0 Following",
                        style: TextStyle(
                            color: Colors.white54, fontSize: width * 0.038)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                      ),
                      child: Text("+ Friends",
                          style: TextStyle(fontSize: width * 0.035)),
                    )
                  ],
                ),
              ),

              // Stats Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: width * 0.025,
                  mainAxisSpacing: width * 0.025,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    statCard("Balance", "51", Icons.star, accentColor, width),
                    statCard("Level", "1", Icons.emoji_events, accentColor,
                        width,
                        label: "Record"),
                    statCard("Current League", "Barefoot", Icons.favorite,
                        accentColor, width),
                    statCard(
                        "Total XP", "30", Icons.flash_on, accentColor, width),
                  ],
                ),
              ),

              // Weekly XP Chart
              Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Weekly XP",
                        style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    SizedBox(height: height * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final heights = [
                          0.18,
                          0.14,
                          0.12,
                          0.10,
                          0.08,
                          0.13,
                          0.17
                        ]; // % height
                        return Container(
                          width: width * 0.025,
                          height: height * heights[index],
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String title, String value, IconData icon, Color color,
      double width,
      {String? label}) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Stack(
        children: [
          if (label != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.025, vertical: width * 0.012),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: width * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: width * 0.06),
              SizedBox(height: width * 0.025),
              Text(value,
                  style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(title,
                  style: TextStyle(
                      fontSize: width * 0.035, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}