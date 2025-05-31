import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signUp(String username, String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Save user info in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'username': username,
      'email': email,
      'password':password,
      'uid': userCredential.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),

    });
  } catch (e) {
    print("Sign up error: $e");
  }
}




Future<void> login(String userInput, String password) async {
  try {
    String email = userInput;

    if (!userInput.contains("@")) {
      // Input is likely a username — fetch associated email
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: userInput)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Username not found");
      }

      email = snapshot.docs.first['email'];
    }

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    print("Login error: $e");
  }
}
