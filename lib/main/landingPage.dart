import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'authenticationPage.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final width = media.size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/landingPageImage.png',
                fit: BoxFit.cover,
              ),
            ),
            // Dark overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.51),
              ),
            ),
            // Foreground content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.07),
              child: Column(
                children: [
                  SizedBox(height: height * 0.57),
                  Text(
                    'Train Your Body\nAnd Mind',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Text(
                    'Your Virtual Coach For Health & Fitness',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: width * 0.035,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9F51B),
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.03),
                        ),
                      ),
                      onPressed: () {
                        print('Get Started tapped');
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 600),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                AuthenticationPage(isReturningUser: true),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: width * 0.036,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: const Color(0xFFB9F51B),
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.039,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print('Sign Up tapped');
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 600),
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      AuthenticationPage(isReturningUser: false),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );

                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.03), // Bottom space
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
