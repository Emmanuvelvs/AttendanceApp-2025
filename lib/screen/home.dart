import 'dart:convert';
//import 'dart:ffi' as ffi;
import 'package:attendance_project_1/screen/Brake_slider.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_project_1/screen/Late_Request.dart';
import 'package:attendance_project_1/screen/Leave_Request.dart' as leaveReq;
import 'package:attendance_project_1/screen/QR_scanner.dart';
import 'package:attendance_project_1/screen/User_delete.dart';
import 'package:attendance_project_1/screen/User_update.dart';
import 'package:attendance_project_1/screen/attendences_ststus.dart';
import 'package:attendance_project_1/screen/login.dart';
import 'package:attendance_project_1/screen/view_leaverequest.dart'
    as viewLeaveReq;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  String? authToken;
  double _slidePosition = 0.0;
  bool _isActive = false;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _slidePosition += details.delta.dx;
      if (_slidePosition < 0) _slidePosition = 0;
      if (_slidePosition > 200) _slidePosition = 200;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_slidePosition > 150) {
        _performAction();

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _slidePosition = 0;
          });
        });
      } else {
        _slidePosition = 0;
      }
    });
  }

  void _performAction() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isActive = !_isActive;
    });

    await prefs.setBool('isActive', _isActive);

    await _saveAttendanceStatus(_isActive);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scanner(type: _isActive ? 'IN' : 'OUT'),
      ),
    );
  }

void logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("userId"); // Remove saved user ID

  print("User logged out");

  // Navigate to Login Page
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (ctx1) => ScreenLogin()),
    (route) => false,
  );
}
  @override
  void initState() {
    super.initState();
    _loadAttendanceStatus();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString("auth_token");
    });
  }

  Future<void> loginUser(BuildContext context) async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "password"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  String username = usernameController.text;
                  String password = passwordController.text;

                  if (username == "admin" && password == "password") {
                    String token =
                        "dummy_token_123"; // Replace with real token from API
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('auth_token', token); // Save token
                    setState(() {
                      authToken = token;
                    });

                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Login successful!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid credentials!")),
                    );
                  }
                },
                child: Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancle"),
              ),
            ],
          );
        });
  }

  void _loadAttendanceStatus() async {
    final prefs = await SharedPreferences.getInstance();

    bool savedState = prefs.getBool('isActive') ?? false;

    print('Loaded _isActive: $savedState');

    setState(() {
      _isActive = prefs.getBool('isActive') ?? false; // Default to false (IN)
    });
  }

Future<bool> isUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("auth_token");
  print("Auth Token: $token");  // Debugging print statement
  return token != null;
}


Future<void> logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Remove stored session ID
  await prefs.remove('sessionId');  
  await prefs.remove('auth_token'); // If needed

  print("Session ID and Token Cleared"); // Debugging

  // Navigate to login screen and prevent going back
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => ScreenLogin()),
    (route) => false, 
  );
}


  Future<void> _saveAttendanceStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActive', value);

    print('Saved _isActive: $value');
  }

  void _handleLateRequest() {
    print('Late Request pressed');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LateRequest()),
    );
  }

  void _handleLeaveRequest() async {
    print('Leave Request button pressed');

    final prefs = await SharedPreferences.getInstance();
    String? userId =
        prefs.getString('userId') ?? prefs.getInt('userId')?.toString();

    if (userId != null && userId.isNotEmpty) {

  List<Map<String, String>> batchData = await _fetchBatches(); // Fetch batch data
List<String> batchOptions = batchData.map((batch) => batch['name'] ?? '').toList(); // Extract only names

if (batchOptions.isNotEmpty) {
  _showBatchSelectionDialog(batchData, userId); // Pass batchData instead of batchOptions
} else {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No batches available. Please try again later.")));
}

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User ID not found. Please log in again.")));
    }
  }

  Future<List<Map<String, String>>> _fetchBatches() async {
    try {
      final response = await http
          .get(Uri.parse("http://185.131.54.8:5050/AdminReg/LeaveWfh"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint("API Response: $data");
       
       return data.map<Map<String, String>>((batch) => {
        'name': batch['name'].toString(),
        'id': batch['id'].toString(),  // Assuming the API returns 'wfhId'
      }).toList();

      } else {
      print("Error: API returned status code ${response.statusCode}");
      return [];
    }
  } catch (e) {
     debugPrint("Network Error: $e");  // ✅ Print error message
    return [];
  }
}

void _showBatchSelectionDialog(List<Map<String, String>> batchOptions, String userId) {
  String? selectedBatch;
  String? selectedWfhId;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Type "),
       content: StatefulBuilder(
  builder: (context, setState) {
    return SizedBox(
      width: double.maxFinite,  // Prevent unnecessary re-renders
      child: DropdownButton<String>(
        value: selectedBatch,
        hint: Text("Choose Type"),
        isExpanded: true,
        onChanged: (newValue) {
          setState(() {
            selectedBatch = newValue;
            selectedWfhId = batchOptions
                .firstWhere((batch) => batch['name'] == newValue, orElse: () => {'id': ''})['id'];

            debugPrint("Selected Batch: $selectedBatch");
    debugPrint("Selected Batch ID: $selectedWfhId");
          });
        },
        items: batchOptions.map((batch) {
          return DropdownMenuItem<String>(
            value: batch['name'],
            child: Text(batch['name']!),
          );
        }).toList(),
      ),
    );
  },
),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
     TextButton(
  onPressed: () {
    if (selectedBatch != null && selectedWfhId != null && selectedWfhId!.isNotEmpty) {
      Navigator.pop(context);
      _navigateToLeaveRequestPage(selectedBatch!, selectedWfhId!, userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a batch")),
      );
    }
  },
  child: Text("Proceed"),
),

        ],
      );
    },
  );
}


  void _navigateToLeaveRequestPage(String batch, String batchId, String userId) {
  debugPrint("Navigating to Leave Request with batchId: $batchId");
  debugPrint("Batch: $batch");
  debugPrint("Batch ID: $batchId");
  debugPrint("User ID: $userId");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          leaveReq.LeaveRequest(userId: userId, batch: batch, batchId: batchId),  // Sending batchId
    ),
  );
}
  void _handleViewLeaverequest() async {
    final prefs = await SharedPreferences.getInstance();

    String? userId =
        prefs.getString('userId') ?? prefs.getInt('userId')?.toString();

    print("Retrieved userId: $userId");

    if (userId != null && userId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              viewLeaveReq.ViewLeaveRequestScreen(userId: userId),
        ),
      );
    } else {
      print('User ID not found');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User ID not found. Please log in again.")));
    }
  }

  void signout(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
  await prefs.remove('sessionId'); // Remove the session ID

  print('User logged out, sessionId cleared.');

    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx1) => ScreenLogin()),
      (route) => false,
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDelete();
                },
                icon: Icon(Icons.delete, color: Colors.white),
                label: Text("Delete"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _handleUpdate();
                },
                icon: Icon(Icons.update, color: Colors.white),
                label: Text("Update"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete() {
    print("Delete button pressed");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeleteUserPage(userId: '')),
    );
  }

  void _handleUpdate() {
    print("Update button pressed");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateUser(userId: '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(fontSize: 30),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              print('person icon pressed');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logoutUser(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Use The Slider Button'),
              SizedBox(height: 20),
              GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: _slidePosition,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isActive ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _isActive ? 'Slide for OUT' : 'Slide for IN',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Action text under slider
              //Text(
              //'Next Action: ${_isActive ? 'OUT' : 'IN'}',
              //style: TextStyle(
              //fontSize: 18,
              //fontWeight: FontWeight.bold,
              //color: Colors.black,
              //),
              //),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _handleLeaveRequest,
                child: Text(
                  'Leave request',
                  style:
                      TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(200, 40),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _handleViewLeaverequest, // Call the function when clicked
                child: Text('View Leave Request'),
              ),

              SizedBox(height: 20),
              GestureDetector(
                onTap: _handleLateRequest,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      'Late Request',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AttendancePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BrakeSlider()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Break Tracker',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'PTF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                print('Settings pressed');
                _showSettingsDialog(context);
              },
            ),
            //SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     print('View Late Request pressed');
            //   },
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: Size(0, 40),
            //     padding: EdgeInsets.symmetric(horizontal: 16),
            //   ),
            //   child: Text('View Late Request'),
            // ),
          ],
        ),
      ),
    );
  }
}
