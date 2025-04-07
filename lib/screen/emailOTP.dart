import 'package:attendance_project_1/screen/ForgotPassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EmailOTPPage extends StatefulWidget {
  @override
  _EmailOTPPageState createState() => _EmailOTPPageState();
}

class _EmailOTPPageState extends State<EmailOTPPage> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter Your Email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendOtp(emailController.text, context);
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
void sendOtp(String email, BuildContext context) async {
  try {

    final response = await http.post(

     Uri.parse("http://185.131.54.8:5050/AdminReg/forgot-password"),
       
       headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
      );
    } else {
      print("Failed to send OTP: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("Error sending OTP: $e");
  }
}
}