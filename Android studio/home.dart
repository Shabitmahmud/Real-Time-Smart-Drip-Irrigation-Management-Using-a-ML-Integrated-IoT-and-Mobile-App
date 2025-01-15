import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'field1.dart'; // Import Field 1 screen
import 'field2.dart'; // Import Field 2 screen

class HomeScreen extends StatefulWidget {
  final UserData userData;

  HomeScreen({required this.userData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String username;
  late String email;

  bool isMonitoringSelected = true;
  bool isGridSelected = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      setState(() {
        username = widget.userData.username;
        email = widget.userData.email;
      });
    } catch (e) {
      // Handle errors
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _updateUserInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateUserInfoScreen(userData: widget.userData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(isGridSelected ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridSelected = !isGridSelected;
              });
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFEDF5ED), // Set the background color here
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person_rounded, size: 50, color: Colors.black),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.account_circle, color: Colors.black, size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${widget.userData.username}',
                              style: TextStyle(color: Colors.black, fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.email_rounded, color: Colors.black, size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${widget.userData.email}',
                              style: TextStyle(color: Colors.black, fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.update),
              title: Text('Update Info'),
              onTap: _updateUserInfo,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),

          ],
        ),
      ),
      body: isGridSelected
          ? GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        children: [
          Card(
            color: Color(0xFFEDF5ED), // Set card background color here
            elevation: 5,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Field1Screen()));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.workspaces_outline, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text('Field 1', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          Card(
            color: Color(0xFFEDF5ED), // Set card background color here
            elevation: 5,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Field2Screen()));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.workspaces_outline, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text('Field 2', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      )
          : ListView(
        padding: EdgeInsets.all(10),
        children: [
          Card(
            color: Color(0xFFEDF5ED), // Set card background color here
            elevation: 5,
            child: ListTile(
              title: Text('Field 1'),
              leading: Icon(Icons.workspaces_outline, color: Colors.blue),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Field1Screen()));
              },
            ),
          ),
          Card(
            color: Color(0xFFEDF5ED), // Set card background color here
            elevation: 5,
            child: ListTile(
              title: Text('Field 2'),
              leading: Icon(Icons.workspaces_outline, color: Colors.blue),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Field2Screen()));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the dialog with the message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xFFEDF5ED),
                title: Text('Coming Soon'),
                content: Text('This feature will be added soon.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
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
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class UpdateUserInfoScreen extends StatelessWidget {
  final UserData userData;

  UpdateUserInfoScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController(text: userData.username);
    TextEditingController passwordController = TextEditingController(text: userData.password);

    return Scaffold(
      appBar: AppBar(
        title: Text('Update User Info'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFFEDF5ED), // Set the background color here
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update User Info',
              style: TextStyle(fontSize: 24.0, color: Colors.lightGreen),
            ),
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('http://127.0.0.1:8000/updateusers/${userData.email}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'username': usernameController.text,
                    'password': passwordController.text,
                    'email': userData.email,
                  }),
                );
                if (response.statusCode == 200) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Success'),
                      content: Text('User information updated successfully'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to update user information'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Update', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
