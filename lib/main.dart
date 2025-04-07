import 'package:attendance_project_1/screen/Leave_Request.dart';
import 'package:attendance_project_1/screen/home.dart';
import 'package:attendance_project_1/screen/login.dart';
import 'package:attendance_project_1/screen/registr.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sessionId = prefs.getString('sessionId');

  runApp(MyApp(initialRoute: sessionId != null ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => ScreenHome(),
        '/login': (context) => ScreenLogin(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId"); // Get user ID

    Future.delayed(Duration(seconds: 2), () {
      if (userId != null && userId.isNotEmpty) {
        // User is logged in → Navigate to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScreenHome()),
        );
      } else {
        // No User ID → Navigate to Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScreenLogin()),
        );
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Check login status on startup
  }
    // Start the timer to navigate to the Home screen
 
 
 Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;


    Future.delayed(Duration(seconds: 2), () { // Optional delay for a splash effect
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ScreenHome()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ScreenLogin()),
        );
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.cyan,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Image.asset('assets/IMG_20241009_150659.jpg'),
              Text(
                'Welcome To P.T.F',
                style:const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  ),
            ),

            SizedBox(height: 20),
            
            CircularProgressIndicator(value: 0.5, color: Colors.blue),
            ],
          ),
        ),
        );
  }
}
 Future<void> setLoginStatus(bool Status) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', Status);
  }
 
          
  
    
  
