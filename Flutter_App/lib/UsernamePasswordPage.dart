import 'package:flutter/material.dart';
import 'package:test_project/requestsList.dart';

import 'UserHomePage.dart';
import 'UserRegistrationForms.dart';

class UsernamePasswordPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String? username = '';
  late String? password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cargo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Replace with your image path
                height: 400, // Set the desired height
                width: 500, // Set the desired width
              ),
              SizedBox(height: 80),
              TextFormField(
                decoration: InputDecoration(labelText: 'User Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your user name';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (username == password) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          username == 'user'
                              ? UserHomePage()
                              : username == 'traveller'
                              ? RequestsListPage()
                              : FormPage(),
                        ),
                      );
                    } else {
                      final snackBar = SnackBar(
                        content: Text('Invaled Username or Password!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                },
                child: Text('LogIn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
