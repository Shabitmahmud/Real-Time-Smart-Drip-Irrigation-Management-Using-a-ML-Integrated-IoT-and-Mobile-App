import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_drip/login.dart';
import 'package:smart_drip/home.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'OTP Generation & Verification',
    theme: ThemeData(
      primaryColor: Color(0xFFEDF5ED), // Custom color from the image
    ),
    initialRoute: '/registration',
    routes: {
      '/login': (context) => LoginScreen(),
      '/registration': (context) => OTPGenerator(),
      '/home': (context) {
        final userData = ModalRoute.of(context)!.settings.arguments as UserData;
        return HomeScreen(userData: userData);
      },
    },
  ));
}

class User {
  final String username;
  final String password;
  final String email;

  User({
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
    };
  }
}

class OTPGenerator extends StatefulWidget {
  @override
  _OTPGeneratorState createState() => _OTPGeneratorState();
}

class _OTPGeneratorState extends State<OTPGenerator> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOTPGenerated = false;
  String _otp = '';
  String _verificationMessage = '';

  Future<void> _createUser() async {
    final user = User(
      username: _usernameController.text,
      password: _passwordController.text,
      email: _emailController.text,
    );

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String message = responseData['msg'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user')),
      );
    }
  }

  Future<void> _generateOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String apiUrl = 'http://localhost:8000/generate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {'email': _emailController.text});

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      print('OTP generated successfully');
      _showOTPDialog();
    } else {
      print('Failed to generate OTP: ${response.body}');
    }
  }

  Future<void> _validateOTP() async {
    final String apiUrl = 'http://localhost:8000/validate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
      'email': _emailController.text,
      'entered_otp': _otpController.text,
    });

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      setState(() {
        _verificationMessage = 'OTP verified successfully';
      });
      _createUser();
    } else {
      setState(() {
        _verificationMessage = 'Failed to verify OTP';
      });
    }
  }

  Future<void> _showOTPDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green.shade50,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water),
            SizedBox(width: 5),
            Text("Smart Drip"),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEDF5ED), // Set the background color here
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    Text(
                      " User SignUp",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    } else if (value.length < 3) {
                      return 'Username must be at least 3 characters long';
                    } else if (!RegExp(r'.[a-zA-Z].').hasMatch(value)) {
                      return 'Username must contain at least 3 letters';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
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
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _generateOTP,
                      icon: Icon(Icons.person_add),
                      label: Text('SignUp'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightGreen,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: Icon(Icons.login),
                      label: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                if (_isOTPGenerated)
                  Text(
                    'OTP Generated: $_otp',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
