import 'dart:io';
import 'package:attendance_project_1/screen/view_laterequests.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class LateRequest extends StatefulWidget {
  @override
  _LateRequestState createState() => _LateRequestState();
}

class _LateRequestState extends State<LateRequest> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserIdFromPreferences();
  }

Future<void> saveUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId); // Fixed key usage
  print('User ID saved: $userId');
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

  Future<void> _getUserIdFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '1'; // Default to an empty string
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Show loading while retrieving userId
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Late Request',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LateRequestForm(userId: userId!), // Pass user ID to the form
    );
  }
}

class LateRequestForm extends StatefulWidget {
  final String userId;

  LateRequestForm({required this.userId}) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
  }

  @override
  _LateRequestFormState createState() => _LateRequestFormState();
}

class _LateRequestFormState extends State<LateRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String val= "";
  String ? userId;
  String? email;
  String? reason;
  DateTime? selectedDate;


@override
void initState(){
  super.initState();
  print("User ID received: ${widget.userId}");
}

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> requestData = {
        'userId':widget.userId,
        'email': email,
        'reason': reason,
        'date': selectedDate!.toIso8601String().split('T')[0],
      };

      final url =
          'http://185.131.54.8:5050/UserReg/late-request?userId=${widget.userId}';
       print('Request URL: $url'); // Log the URL for debugging
        print('Request Data: $requestData');
        
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode > 299) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Late request submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed: ${response.statusCode} ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
  title: Text('Late Request'),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 10), // Adjust spacing
      child: SizedBox(
        height: 30, // Reduce height
        width: 140, // Reduce width
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // White inside
            side: BorderSide(color: Color.fromARGB(255, 69, 77, 69), width: 2), // Border
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded edges
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller padding
            minimumSize: Size(100, 30), // Set minimum size
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LateRequestScreen(userId: int.parse(widget.userId)),
              ),
            );
          },
          child: Text(
            'View Late Requests',
            style: TextStyle(color: Colors.black, fontSize: 12), // Smaller font
          ),
        ),
      ),
    ),
  ],
),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Late Type'),
                items: <String>['Traffic', 'Emergency', 'Sick']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a late type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    reason = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                validator: (value) {
                  if (selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: selectedDate != null
                      ? "${selectedDate!.toLocal()}".split(' ')[0]
                      : '',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}  