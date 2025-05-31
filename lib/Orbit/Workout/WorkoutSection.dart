import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'WorkoutModel.dart';

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key});

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  List<Exercise> exercises = [];
  bool isLoading = true;

  Future<List<Exercise>> fetchExercises(String muscle, {int limit = 10, int offset = 0}) async {
    final url = Uri.https(
      'exercisedb.p.rapidapi.com',
      '/exercises/bodyPart/$muscle',
      {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final response = await http.get(
      url,
      headers: {
        'X-RapidAPI-Key': 'c2d32c73b9msh424a25d23da6275p1dc20fjsn7dabfd8f6734',
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      },
    );

    /*
    final url = Uri.parse("https://ai-workout-planner-exercise-fitness-nutrition-guide.p.rapidapi.com/generateWorkoutPlan?noqueue=1");

    final response = await http.post(
      url,
      headers: {
        'X-RapidAPI-Key': 'c2d32c73b9msh424a25d23da6275p1dc20fjsn7dabfd8f6734',
        'X-RapidAPI-Host': 'ai-workout-planner-exercise-fitness-nutrition-guide.p.rapidapi.com',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "goal": "Build muscle",
        "fitness_level": "Intermediate",
        "preferences": ["Weight training", "Cardio"],
        "health_conditions": ["None"],
        "schedule": {"days_per_week": 4, "session_duration": 60},
        "plan_duration_weeks": 4,
        "lang": "en"
      }),
    );
    */

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      print(response.body);
      throw Exception('Failed to load exercises: ${response.statusCode}');
    }
  }


  DateTime today = DateTime.now();
  late List<DateTime> weekDates;
  late DateTime selectedDate;
  List<DateTime> generateWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  void initState() {
    super.initState();
    loadExercises();
    selectedDate = today;
    weekDates = generateWeek(today);
  }

  Future<void> loadExercises() async {
    try {
      final data = await fetchExercises("back");
      setState(() {
        exercises = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading exercises: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top greeting row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, Martin',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(DateFormat('EEEE d MMM').format(today),
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const CircleAvatar(
                  radius: 22,
                  backgroundImage:
                  AssetImage('assets/images/profile.jpg'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Daily Challenge Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFB3FF4A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Challenge',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 8),
                        Text('Do your plan before 09:00 AM',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(
                            4,
                                (index) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundImage: AssetImage(
                                    'assets/images/landingPageImage.png'),
                              ),
                            ),
                          )..add(const Text("+4",
                              style: TextStyle(color: Colors.black))),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/landingPageImage.png',
                    height: 100,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Interactive Calendar (horizontal scrollable)
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: weekDates.map((date) {
                    final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                          isSelected ? Color(0xFFB3FF4A) : const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${date.day}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}