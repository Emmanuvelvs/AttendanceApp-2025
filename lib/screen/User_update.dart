import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUser extends StatefulWidget {
  final String userId;

  UpdateUser({required this.userId});

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _EmailidController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _passwordcontroller;
  late TextEditingController _batchController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _EmailidController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _passwordcontroller = TextEditingController();
    _batchController = TextEditingController();
    _fetchUserDetails(); // Fetch existing user details
  }

  @override
  void dispose() {
    _nameController.dispose();
    _EmailidController.dispose();
    _phoneNumberController.dispose();
    _passwordcontroller.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    print("Fetching details for userId: ${widget.userId}");
    final String apiUrl = 'http://103.247.19.200:5050/user/${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Code: ${response.statusCode}");

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['name'] ?? '';
          _EmailidController.text = data['email'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _batchController.text = data['batch'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  void _navigateToUpdateUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UpdateUser(userId: userId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
      );
    }
  }

  Future<void> _updateUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String apiUrl =
          'http://103.247.19.200:5050/user/update ${widget.userId}';

      final Map<String, dynamic> userDetails = {
        'userId': widget.userId,
        'name': _nameController.text,
        'email': _EmailidController.text,
        'phoneNumber': _phoneNumberController.text,
        'password': _passwordcontroller.text,
        'batch': _batchController.text,
      };

      print("Updating user with data: $userDetails");

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userDetails),
        );

        print("Response Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update user')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update User")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _EmailidController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: "PhoneNumber"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "PhoneNumber cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordcontroller,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "password cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(labelText: "Batch"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Batch cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
