import 'dart:convert';
import 'package:attendance_project_1/main.dart';
import 'package:attendance_project_1/screen/ForgotPassword.dart';
import 'package:attendance_project_1/screen/QR_scanner.dart';
import 'package:attendance_project_1/screen/emailOTP.dart';
import 'package:attendance_project_1/screen/registr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_project_1/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenLogin extends StatefulWidget {
  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isDataMatched = true;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  //String ? _userId; //add this line to store the user ID

  //final String apiUrl = "http://192.168.1.42:8080/UserReg/login";
  final String apiUrl = "http://185.131.54.8:5050/UserReg/login";

  Future<void> saveUserToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    print('Login state saved: $isLoggedIn');
  }

  Future<void> login(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    print('User ID saved: $userId');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    print('Login state cleared');
  }

  void signout(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance;

    await clearLoginState(); // Clear login state

    print('User logged out');

    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx1) => ScreenLogin()),
      (route) => false,
    );
  }

  Future<void> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final response = {
      "id": 6,
      "email": "anu@gmail.com",
      "name": "anu",
      "batchId": 3,
      "batchName": "Startup Batch",
      "token": "60dc9125-c156-47b5-b4d6-3f4bd5330402",
      "message": "Login Successfully"
    };

    if (response.containsKey("id")) {
      await prefs.setString(
          "userId", response["id"].toString()); // Save user ID
      print("User ID saved: ${response["id"]}");
    }

    // Navigate to Home Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ScreenHome()),
    );
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    print("User ID cleared");
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    print('User ID saved: $userId');
  }

  Future<void> checkLogin(BuildContext ctx) async {
    final _email = _emailController.text;
    final _password = _passwordController.text;

    final Map<String, dynamic> data = {
      'email': _email,
      'password': _password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);

        // Check if login was successful
        if (responseData.containsKey("permanentSessionId")) {
          String sessionId = responseData["permanentSessionId"];

          // Save sessionId in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('sessionId', sessionId);

          print("Session ID saved: $sessionId");

          // Navigate to Home Page
          Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(builder: (ctx1) => ScreenHome()),
          );
        } else {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Login Failed: Invalid credentials')),
          );
        }
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Login Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.greenAccent
            ], // Match registration page
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Adjust horizontal padding
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the start
              children: [
                SizedBox(height: 100), // Space at the top
                Text(
                  'Login', // Your top text
                  style: TextStyle(
                    fontSize: 50, // Adjust size
                    fontWeight: FontWeight.bold, // Make it bold
                    color: Colors.white, // Set text color to white for contrast
                  ),
                ),
                SizedBox(height: 20), // Space between text and form
                Expanded(
                  // Expanded to center the form content vertically
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Use minimal vertical space
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center vertically
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              } else if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height:
                                  20), // Space between email and password fields
                          // TextFormField(
                          //   controller: _passwordController,
                          //   obscureText: true,
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                          //     enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          //     focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                          //     hintText: 'Password',
                          //     hintStyle: TextStyle(color: Colors.black),
                          //   ),
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Password is required';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          //        SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock,
                            obscureText: _isPasswordVisible,
                            isPasswordField: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) =>EmailOTPPage()),
                                  );
                              },
                              child: Text(
                                'Forgot PassWord?',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                checkLogin(context);
                              }
                            },
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text('Login',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent),
                          ),
                          SizedBox(height: 20),

                          TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => Registr()),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurpleAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPasswordField = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordField ? obscureText : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(30),
          ),
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }
}
