import 'dart:async';
import 'package:flutter/material.dart';

import 'LogInRegistrationPage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // Start the timer
    Timer(Duration(seconds: 3), () {
      // Set the visibility of the logo to false
      setState(() {
        _isVisible = false;
      });

      // Redirect to the next page
      navigateToNextPage();
    });
  }

  void navigateToNextPage() {
    // Navigate to the next page using Navigator
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LogInRegistrationLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 500),
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WelcomePage(),
  ));
}
