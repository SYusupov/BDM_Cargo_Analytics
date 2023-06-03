import 'package:flutter/material.dart';
import 'package:test_project/requestsList.dart';

import 'UserRegistrationForms.dart';
import 'UsernamePasswordPage.dart';

class LogInRegistrationLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cargo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your image path
              height: 400, // Set the desired height
              width: 500, // Set the desired width
            ),
            SizedBox(height: 80),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsernamePasswordPage(),
                    ),
                  );
                },
                // onPressed: () {
                //   Functions functions = new Functions();
                //   functions.sendRequest();
                // },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text('Log In'),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
