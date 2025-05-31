import 'package:flutter/material.dart';
import 'package:health_sphere/Orbit/Workout/WorkoutSection.dart';

import '../../Orbit/HomePage.dart';
import '../../Orbit/Notes/NotesScreen.dart';



class PageNavigation extends StatefulWidget {
  const PageNavigation({super.key});

  @override
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    Placeholder(),
    NotesScreen(),
    FitnessHomePage(),
    Placeholder(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF101010),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFB9F51B),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: iconSize + 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
