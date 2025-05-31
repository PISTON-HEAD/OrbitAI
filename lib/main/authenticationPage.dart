import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:health_sphere/main/BottomNavigation/PageNavigation.dart';
import 'package:lottie/lottie.dart';

class AuthenticationPage extends StatefulWidget {
  final bool isReturningUser;

  const AuthenticationPage({super.key, required this.isReturningUser});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool isPasswordVisible = false;
  late bool isReturningUser;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    isReturningUser = widget.isReturningUser;
  }

  Future<void> signUp(String username, String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
       await userCredential.user!.updateDisplayName(username);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'password': password, // Add the password to the Firestore document'
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PageNavigation()), // Replace with your target page
      );
    } catch (e) {
      showErrorSnackBar(e.toString());
    }
  }

  Future<void> login(String userInput, String password) async {
    try {

      String email = userInput;

      if (!userInput.contains("@")) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: userInput)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) throw Exception("Username not found");

        email = snapshot.docs.first['email'];
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PageNavigation()), // Replace with your target page
      );
    } catch (e) {
      showErrorSnackBar(e.toString());
    }
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  InputDecoration _inputDecoration(String hint, double width) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final width = media.size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.21,
              child: Lottie.asset(
                'assets/lottie/authPageAnimation.json',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.07),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.024),
                        Text(
                          isReturningUser ? 'Welcome Back!' : 'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.08,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.012),
                        Text(
                          isReturningUser
                              ? 'Login to continue your journey'
                              : 'Join us to start training your body & mind!',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: width * 0.035,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.021),

                        if (!isReturningUser)
                          Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                style: TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Username', width),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Username is required';
                                  } else if (value.trim().length < 4) {
                                    return 'At least 4 characters';
                                  } else if (value.contains(' ')) {
                                    return 'No spaces allowed';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: height * 0.02),
                            ],
                          ),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Email or Username', width),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email or Username is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !isPasswordVisible,
                          enabled: !_isLoading,
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Password', width).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 8) {
                              return 'Minimum 8 characters';
                            } else if (value.contains(' ')) {
                              return 'No spaces allowed';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.03),

                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB9F51B),
                                padding: EdgeInsets.symmetric(
                                  vertical: height * 0.018,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(width * 0.03),
                                ),
                                elevation: 8,
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                 setState(() => _isLoading=true);
                                  if (isReturningUser) {
                                    await login(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  } else {
                                    await signUp(
                                      _usernameController.text.trim(),
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  }
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: Text(
                                isReturningUser ? 'Login' : 'Sign Up',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: height * 0.025),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white30)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'OR',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white30)),
                          ],
                        ),

                        SizedBox(height: height * 0.012),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AuthButton(
                              icon: 'assets/images/google.png',
                              onTap: () => print('Google Auth tapped'),
                            ),
                            SizedBox(width: width * 0.07),
                            AuthButton(
                              icon: 'assets/images/apple.png',
                              onTap: () => print('Apple Auth tapped'),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.021),

                        Text.rich(
                          TextSpan(
                            text: isReturningUser
                                ? "Don't have an account? "
                                : "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: width * 0.036,
                            ),
                            children: [
                              TextSpan(
                                text: isReturningUser ? 'Sign Up' : 'Login',
                                style: TextStyle(
                                  color: Color(0xFFB9F51B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.039,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      isReturningUser = !isReturningUser;
                                      _formKey.currentState?.reset();
                                      _emailController.clear();
                                      _passwordController.clear();
                                      _usernameController.clear();
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const AuthButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(icon, height: 30),
      ),
    );
  }
}

