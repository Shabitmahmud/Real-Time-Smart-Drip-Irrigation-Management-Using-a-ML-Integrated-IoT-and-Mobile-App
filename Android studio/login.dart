// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'home.dart'; // Import the home screen file
//
// // Class to represent user data
// class UserData {
//   final String username;
//   final String email;
//   final String password;
//
//   UserData({required this.username, required this.email, required this.password});
// }
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     final String loginUrl = 'http://localhost:8000/login/';
//     final Uri loginUri = Uri.parse(loginUrl).replace(
//       queryParameters: {
//         'username': _usernameController.text,
//         'password': _passwordController.text,
//       },
//     );
//
//     try {
//       final http.Response loginResponse = await http.post(loginUri);
//
//       if (loginResponse.statusCode == 200) {
//         // Login successful, fetch user email
//         final String userInfoUrl = 'http://localhost:8000/user_info/${_usernameController.text}';
//         final Uri userInfoUri = Uri.parse(userInfoUrl);
//
//         final http.Response userInfoResponse = await http.get(userInfoUri);
//
//         if (userInfoResponse.statusCode == 200) {
//           final Map<String, dynamic> userDataJson = jsonDecode(userInfoResponse.body);
//           final String userEmail = userDataJson['email'];
//
//           // Update user data with retrieved email
//           final UserData userData = UserData(
//             username: _usernameController.text,
//             email: userEmail,
//             password: _passwordController.text,
//           );
//
//           // Print user info to console
//           print('User Info:');
//           print('Username: ${userData.username}');
//           print('Email: ${userData.email}');
//           print('Password: ${userData.password}');
//
//           // Navigate to the home screen and pass user data
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)),
//           );
//         } else {
//           // Failed to fetch user info
//           final String error = jsonDecode(userInfoResponse.body)['detail'];
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to fetch user info: $error'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } else {
//         // Login failed
//         final String error = jsonDecode(loginResponse.body)['detail'];
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Login failed: $error'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       // Handle network or other errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to connect to the server.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       print('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//         backgroundColor: Colors.cyan, // Set app bar color
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.person),
//                   Text(
//                     " User Login",
//                     style: TextStyle(
//                       fontSize: 24, // Adjusting the font size
//                       color: Colors.black, // Changing text color
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a username';
//                   } else if (value.length < 3) {
//                     return 'Username must be at least 3 characters long';
//                   } else if (!RegExp(r'.[a-zA-Z].').hasMatch(value)) {
//                     return 'Username must contain at least 3 letters';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.0),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a password';
//                   } else if (value.length < 8) {
//                     return 'Password must be at least 8 characters long';
//                   } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
//                     return 'Password must contain at least one letter and one number';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: _login,
//                 child: Text('Login'),
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.cyan, // Set button color
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacementNamed(context, '/registration');
//                 },
//                 child: Text('Sign Up'),
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.lightGreenAccent, // Set text color
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart'; // Import the home screen file
import 'forget_password.dart'; // Import the forget_password.dart file


// Class to represent user data
class UserData {
  final String username;
  final String email;
  final String password;

  UserData({required this.username, required this.email, required this.password});
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String loginUrl = 'http://localhost:8000/login/';
    final Uri loginUri = Uri.parse(loginUrl).replace(
      queryParameters: {
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    try {
      final http.Response loginResponse = await http.post(loginUri);

      if (loginResponse.statusCode == 200) {
        // Login successful, fetch user email
        final String userInfoUrl = 'http://localhost:8000/user_info/${_usernameController.text}';
        final Uri userInfoUri = Uri.parse(userInfoUrl);

        final http.Response userInfoResponse = await http.get(userInfoUri);

        if (userInfoResponse.statusCode == 200) {
          final Map<String, dynamic> userDataJson = jsonDecode(userInfoResponse.body);
          final String userEmail = userDataJson['email'];

          // Update user data with retrieved email
          final UserData userData = UserData(
            username: _usernameController.text,
            email: userEmail,
            password: _passwordController.text,
          );

          // Print user info to console
          print('User Info:');
          print('Username: ${userData.username}');
          print('Email: ${userData.email}');
          print('Password: ${userData.password}');

          // Navigate to the home screen and pass user data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)),
          );
        } else {
          // Failed to fetch user info
          final String error = jsonDecode(userInfoResponse.body)['detail'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch user info: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Login failed
        final String error = jsonDecode(loginResponse.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $e');
    }
  }

  // Function to navigate to the forget password screen
  void _navigateToForgetPasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgetPasswordScreen()), // Replace ForgetPassActivity with the name of your activity
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.green, // Set app bar color
      ),
      backgroundColor: Color(0xFFEDF5ED),
      body: Padding(
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
                    " User Login",
                    style: TextStyle(
                      fontSize: 24, // Adjusting the font size
                      color: Colors.black, // Changing text color
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
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
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
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
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen, // Set button color
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/registration');
                },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen, // Set text color
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: _navigateToForgetPasswordScreen,
                child: Text('Forget Password'), // Text for the button
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen, // Set text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
