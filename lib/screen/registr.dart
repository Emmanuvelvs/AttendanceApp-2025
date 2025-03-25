import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:attendance_project_1/screen/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Registr extends StatefulWidget {
  Registr({Key? key}) : super(key: key);

  @override
  State<Registr> createState() => _RegistrState();
}

class _RegistrState extends State<Registr> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _EmailidController = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _batchController = TextEditingController();
   

  bool _isSubmitting = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoadingBatches = false;
  //List<String> _batchList = [];

List<Map<String, dynamic>> _batchList = []; // Store batch as dynamic list
  Map<String, dynamic>? _selectedBatch; // Store selected batch as an object
  
  final RegExp _emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  //final String apiUrl = 'http://192.168.1.42:8080/UserReg/reg'; 
 final String apiUrl = 'http://103.247.19.200:5050/UserReg/reg';
final String batchApiUrl = 'http://103.247.19.200:5050/AdminReg/getAllBatches';
//String _selectedBatch = 'Batch'; 

@override
void initState(){
  super.initState();
 // _batchController.text = _selectedBatch;
  _fetchBatches();
}

@override
void dispose() {
  _nameController.dispose();
  _phoneNumberController.dispose();
  _EmailidController.dispose();
  _passwordcontroller.dispose();
  _confirmpasswordController.dispose();
  _batchController.dispose(); 
  super.dispose();
}

Future<void> _fetchBatches() async {
  setState(() {
    _isLoadingBatches = true;
  });

  try {
    final response = await http.get(Uri.parse(batchApiUrl));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic>? responseData = json.decode(response.body);

      if (responseData != null) {
        print("Batch API Response: $responseData"); // Debugging log

        setState(() {
          _batchList = responseData
              .where((batch) => batch != null && batch is Map<String, dynamic>)
              .map((batch) => {
                    'id': batch['id']?.toString() ?? '', 
                    'name': batch['batchName']?.toString() ?? "Unknown Batch"
                  })
              .toList();

          print("Parsed Batch List: $_batchList"); // Debugging log
        });
      }
    } else {
      throw Exception("Failed to load batches: ${response.statusCode}");
    }
  } catch (error) {
    print("Batch Fetch Error: $error"); // Debugging log
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading batches: $error')),
    );
  } finally {
    setState(() {
      _isLoadingBatches = false;
    });
  }
}




  Future<void> _registerUser() async {
  setState(() {
    _isSubmitting = true;
  });

  if(_selectedBatch == null){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('please select a batch')),
    );
    setState(() {
      _isSubmitting = false;
    });
    return;
  }

final String batchId = _selectedBatch?['id']?.toString()??'';

if(batchId.isEmpty){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Batch ID is invalid!')),
  );
  setState(() {
    _isSubmitting = false;
  });
  return;
}

  final String name = _nameController.text;
  final String phoneNumber = _phoneNumberController.text;
  final String email = _EmailidController.text;
  final String password = _passwordcontroller.text;
  //final String batchId = _selectedBatch? ['id']?.toString()?? ''; 


  final Map<String, dynamic> data = {
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'password': password,
    'batchId': batchId,
  };

try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = json.decode(response.body);
      final String? userId = responseData['userId']?.toString();

      if (userId != null && userId.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScreenLogin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: userId is null or empty')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: ${response.body}')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error occurred: $error')),
    );
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
}


  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : () {
          if (_formkey.currentState!.validate()) {
            _registerUser(); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill in all fields correctly')),
            );
          }
        },
        icon: Icon(Icons.check, color: Colors.white),
        label: Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneNumberController,
                      hint: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _EmailidController,
                      hint: 'Email ID',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        } else if (!_emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordcontroller,
                      hint: 'Password',
                      icon: Icons.lock,
                      obscureText: _isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      isPasswordField: true,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _confirmpasswordController,
                      hint: 'Confirm Password',
                      icon: Icons.lock,
                      obscureText: _isConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordcontroller.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      isPasswordField: true,
                    ),
                    SizedBox(height: 20),
                    _buildBatchDropdown(),
                    SizedBox(height: 60),
                    _buildSubmitButton(),
                    SizedBox(height: 10),
                    
                  ],
                ),
              ),
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
                  icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      if (controller == _passwordcontroller) {
                        _isPasswordVisible = !_isPasswordVisible;
                      } else if (controller == _confirmpasswordController) {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      }
                    });
                  },
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildBatchDropdown() {
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
        controller: _batchController
        ..text =  _selectedBatch?['name']?.toString()?? "Select Batch",
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.access_alarm, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          hintText: _isLoadingBatches ? "Loading..." : "Select Batch",
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(30),
          ),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
        ),
        onTap: () async {
        if (_batchList.isEmpty) {
          print("Batch list is empty, fetching batches...");
          await _fetchBatches();
        }

        print("Batch list : $_batchList");

        Map<String, dynamic>? selected = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('Select Batch'),
              children: _batchList.map((batch) {
                print("Batch Option :$batch");
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, batch);
                  },
                  child: Text(batch['name'] ?? "Unknown Batch"),
                );
              }).toList(),
            );
          },
        );

        if (selected != null && selected.containsKey('name') && selected['name'] != null) {
           print('Selected Batch: $selected');
           print('Selected Batch Name: ${selected?['name']}');
 
  setState(() {
    _selectedBatch = selected;
    _batchController.text = selected['name'].toString(); 
  });
}else{
  print('No batch selected.');
  setState(() {
    _batchController.text = "Select Batch";
  });
}
      },
    ),
  );
}
}


