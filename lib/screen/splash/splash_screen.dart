import 'dart:async';
import 'package:doctorspoint/screen/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import your login screen here

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer that navigates to the login screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginScreen()), // Navigate to the login screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Center(
        child: Lottie.asset('assets/doctor.json'),
      ),
    );
  }
}
