

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isOTPGenerated = false;
  bool _isOTPSuccessful = false;
  String _verificationMessage = '';

  Future<void> _generateOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String apiUrl = 'http://localhost:8000/generate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(
        queryParameters: {'email': _emailController.text});

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      setState(() {
        _isOTPGenerated = true;
        _verificationMessage = '';
      });

      _showOTPDialog();
    } else {
      setState(() {
        _isOTPGenerated = false;
        _verificationMessage = 'Failed to generate OTP';
      });
    }
  }

  Future<void> _validateOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String apiUrl = 'http://localhost:8000/validate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
      'email': _emailController.text,
      'entered_otp': _otpController.text,
    });

    final response = await http.post(uri, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      setState(() {
        _verificationMessage = 'OTP verified successfully';
        _isOTPSuccessful = true;
      });
      await _fetchUsernameAndPassword(_emailController.text);
    } else {
      setState(() {
        _verificationMessage =
        'Failed to verify OTP: ${jsonDecode(response.body)['detail']}';
        _isOTPSuccessful = false;
      });
    }
  }

  Future<void> _fetchUsernameAndPassword(String email) async {
    final String apiUrl = 'http://localhost:8000/get_user_info/$email';
    final Uri uri = Uri.parse(apiUrl);

    final response = await http.get(uri, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _usernameController.text = data['username'];
        _passwordController.text = data['password'];
      });
    } else {
      setState(() {
        _verificationMessage = 'Failed to fetch user info';
      });
    }
  }

  Future<void> _showOTPDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEDF5ED),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'OTP'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Set button color
              ),

            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _validateOTP();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Verify'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Set button color
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserInfo() async {
    final String apiUrl = 'http://localhost:8000/updateusers/${_emailController.text}';
    final Uri uri = Uri.parse(apiUrl);

    final Map<String, dynamic> userData = {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'email': _emailController.text, // Include email address in the request body
    };

    final response = await http.put(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      // User information updated successfully
      print('User information updated successfully');
      _showSuccessDialog(); // Call function to show success dialog
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEDF5ED),
          title: Text('Update Successful'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your information has been updated successfully.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to login page
                Navigator.of(context).popUntil(ModalRoute.withName('/login'));
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Set button color
              ),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    print('Building UI...');
    return Scaffold(
      appBar: AppBar(
        title: Text('Forget Password'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFFEDF5ED),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _generateOTP,
                child: Text('Generate OTP'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen, // Set text color
                ),
              ),
              if (_isOTPGenerated)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'OTP'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter OTP';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _validateOTP,
                        child: Text('Verify OTP'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightGreen, // Set button color
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        _verificationMessage,
                        style: TextStyle(
                          color: _verificationMessage.contains('successfully')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isOTPSuccessful)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        readOnly: false,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          } else if (value.length < 3) {
                            return 'Username must be at least 3 characters long';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        readOnly: false,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                            return 'Password must contain at least one letter and one number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _updateUserInfo();
                          }
                        },
                        child: Text('Update'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightGreen, // Set button color
                        ),
                      ),
                    ],
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
