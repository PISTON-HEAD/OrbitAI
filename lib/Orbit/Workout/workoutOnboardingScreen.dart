import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutOnboardingScreen extends StatefulWidget {
  @override
  _WorkoutOnboardingScreenState createState() => _WorkoutOnboardingScreenState();
}

class _WorkoutOnboardingScreenState extends State<WorkoutOnboardingScreen> {
  int age = 25;
  double height = 170;
  double weight = 65;
  double goalWeight = 60;
  int daysPerWeek = 3;
  String goal = "Lose Weight";
  DateTime? birthday;

  int currentPage = 0;

  final List<String> goals = ["Lose Weight", "Build Muscle", "Stay Fit"];

  void saveData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser?.uid).collection("goal").doc(Timestamp.now().seconds.toString()).set({
      'BirthDate':birthday,
      'age': age,
      'height': height,
      'weight': weight,
      'goalWeight': goalWeight,
      'goal': goal,
      'daysPerWeek': daysPerWeek,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    Navigator.pushReplacementNamed(context, '/navigation');
  }

  void nextPage() {
    if (currentPage < 5) {
      setState(() => currentPage++);
    } else {
      saveData();
    }
  }

  Widget buildQuestion(String title, Widget picker) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 20),
        picker,
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: nextPage,
          child: Text(currentPage < 5 ? "Next" : "Finish"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [
      buildQuestion(
        "When is your Birthday?",
        SizedBox(
          height: 150,
          child: CupertinoDatePicker(
            backgroundColor: Colors.black,
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime(2002, 1, 1),
            maximumDate: DateTime.now(),
            minimumYear: 1900,
            maximumYear: DateTime.now().year,
            onDateTimeChanged: (DateTime newDate) {
             birthday = newDate; // make sure you have a variable like: DateTime? birthday;
            },
          ),
        ),
      ),
      buildQuestion("How old are you?", SizedBox(
        height: 100,
        child: CupertinoPicker(
          backgroundColor: Colors.black,
          itemExtent: 39,
          scrollController: FixedExtentScrollController(initialItem: age - 10),
          onSelectedItemChanged: (value) => age = value + 10,
          children: List.generate(growable: true,90, (index) => Text("${index + 10}", style: TextStyle(color: Colors.white))),
        ),
      )),
      buildQuestion("Your current weight (kg)?", SizedBox(
        height: 100,
        child: CupertinoPicker(
          backgroundColor: Colors.black,
          itemExtent: 39,
          scrollController: FixedExtentScrollController(initialItem: weight.toInt() - 30),
          onSelectedItemChanged: (value) => weight = value + 30,
          children: List.generate(120, (index) => Text("${index + 30}", style: TextStyle(color: Colors.white))),
        ),
      )),
      buildQuestion("Your height (cm)?", SizedBox(
        height: 100,
        child: CupertinoPicker(
          backgroundColor: Colors.black,
          itemExtent: 39,
          scrollController: FixedExtentScrollController(initialItem: height.toInt() - 100),
          onSelectedItemChanged: (value) => height = value + 100,
          children: List.generate(100, (index) => Text("${index + 100}", style: TextStyle(color: Colors.white))),
        ),
      )),
      buildQuestion("What is your goal?", SizedBox(
        height: 100,
        child: CupertinoPicker(
          backgroundColor: Colors.black,
          itemExtent: 39,
          onSelectedItemChanged: (value) => goal = goals[value],
          children: goals.map((g) => Text(g, style: TextStyle(color: Colors.white))).toList(),
        ),
      )),
      buildQuestion("Goal Weight (kg)?", SizedBox(
        height: 100,
        child: CupertinoPicker(
          backgroundColor: Colors.black,
          itemExtent: 32,
          scrollController: FixedExtentScrollController(initialItem: goalWeight.toInt() - 30),
          onSelectedItemChanged: (value) => goalWeight = value + 30,
          children: List.generate(120, (index) => Text("${index + 30}", style: TextStyle(color: Colors.white))),
        ),
      )),
      buildQuestion("How many days a week?", SizedBox(
        height: 100,
        child: CupertinoPicker(

          backgroundColor: Colors.black,
          itemExtent: 32,
          scrollController: FixedExtentScrollController(initialItem: daysPerWeek - 1),
          onSelectedItemChanged: (value) => daysPerWeek = value + 1,
          children: List.generate(7, (index) => Text("${index + 1}x", style: TextStyle(color: Colors.white))),
        ),
      )),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: steps[currentPage]),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              //child: Lottie.asset('assets/animations/progress${currentPage + 1}.json', height: 100),
              child: Lottie.asset("assets/lottie/authPageAnimation.json",height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
