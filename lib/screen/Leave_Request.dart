import 'dart:io';

import 'package:attendance_project_1/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // For JSON encoding/decoding
import 'package:attendance_project_1/screen/Leave_Request.dart';



class LeaveRequest extends StatefulWidget {
  final String userId;
     final String batch;

  const LeaveRequest({Key? key,required this.userId, required this.batch }):super(key: key);

  @override

  _LeaveRequestState createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {

//String val = "";
String? userId;

  @override
  void initState(){
    super.initState();
    _getUserIdFromPreferences();
    _initializeUserId();
   //debugPrint('Received User ID in LeaveRequest: ${widget.userId}');
   //if (widget.userId.isEmpty){
   //_getuserId(); 
  }

  Future<void> _initializeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');

    if (widget.userId.isNotEmpty) {
      setState(() {
        userId = savedUserId ?? widget.userId;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('userId') ?? '';
      });
    }
    debugPrint('Initialized User ID: $userId');
  }



Future<void> _getUserIdFromPreferences() async{
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    userId = prefs.getString('userId') ?? '';
  });
  //debugPrint('Fetched User ID from SharedPreferences: $userId');
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}
 

  String? _leaveType;
  String _reason = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _numberOfDays = 0;
  String? _status;
  final List<String> _leaveTypes = ['Sick Leave', 'Casual Leave'];

  void _calculateTotalDays() {
    if (_fromDate != null && _toDate != null) {
      setState(() {
        _numberOfDays = _toDate!.difference(_fromDate!).inDays + 1;
      });
    }
  }

Future<void> saveUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId); // Use 'userId' as the key
 print('User ID saved: $userId');
}

Future<void> checkLogin(BuildContext ctx) async{

}

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = selectedDate;
          if (_toDate != null && _fromDate!.isAfter(_toDate!)) {
            _toDate = null;
          }
        } else {
          _toDate = selectedDate;
          if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
            _fromDate = null;
          }
        }
        _calculateTotalDays();
      });
    }
  }

Future<void> _submitLeaveRequest() async {
  
  final userIdFinal = userId ?? widget.userId;
  
if (userId == null || userIdFinal.isEmpty){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('User Id is missing! please try again.')),
  );

return;

}

final userIdInt = int. tryParse(userIdFinal);

if(userIdInt == null){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('user id is invalid')),
  );
  return;
}

  if (_leaveType == null || _fromDate == null || _toDate == null || _reason.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Please fill in all required fields')),


);
//debugPrint('Submitting leave request with userId: ${widget.userId}');

    return;
  }

// int? userIdAsLong;
// try{
//   userIdAsLong = int.parse(userId);
// }catch(e){
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content:Text('Invalid userId format!')),
//     );
//     return;
//}

 final url = Uri.parse("http://103.247.19.200:5050/UserReg/leave-request?userId=$userId&wfh=${widget.batch}");

  final requestData = {
    'userId': userIdInt,
    'leaveType': _leaveType,
    'reason': _reason,
    'fromDate': _fromDate!.toIso8601String(),
    'toDate': _toDate!.toIso8601String(),
    'numberOfDays': _numberOfDays,
  };

debugPrint('Request Data: ${jsonEncode(requestData)}');
  try {
   final response = await http.post(
  url, // ✅ No need to parse again
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(requestData),
);

    if (response.statusCode == 200 || response.statusCode ==201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: 
        Text('Leave request submitted successfully')),
      );
      final responseData = jsonDecode(response.body);
      setState(() {
        _status = responseData['status'] ?? 'Pending';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave request submitted successfully')),
      );
    } else {
      throw Exception('Failed: ${response.reasonPhrase}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leave Request for user: ${widget.userId}'),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Leave Type'),
              items: _leaveTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _leaveType = value;
                });
              },
              value: _leaveType,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Reason'),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _reason = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'From Date: ${_fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : 'Not selected'}',
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: Text('Select From Date'),
            ),
            SizedBox(height: 16),
            Text(
              'To Date: ${_toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : 'Not selected'}',
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context, false),
              child: Text('Select To Date'),
            ),
            SizedBox(height: 16),
            Text('Total Days: $_numberOfDays'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitLeaveRequest,
              child: Text('Submit Leave Request'),
            ),
            if (_status != null) ...[
  SizedBox(height: 16),
  Text(
    'Request Status: $_status',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _status == 'Approved'
          ? Colors.green
          : _status == 'Rejected'
              ? Colors.red
              : Colors.orange, // Pending
    ),
  ),
],
          ],
        ),
      ),
    );
  }
} 