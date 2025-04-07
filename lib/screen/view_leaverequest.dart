import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_project_1/screen/view_leaverequest.dart';



class LeaveRequest {
  final int id;
  final int userId;
  final String name;
  final int batchId;
  final String leaveType;
  final String reason;
  final String fromDate;
  final String toDate;
  final int numberOfDays;
  final String status;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.name,
    required this.batchId,
    required this.leaveType,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.numberOfDays,
    required this.status,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      batchId: json['batchId'],
      leaveType: json['leaveType'],
      reason: json['reason'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      numberOfDays: json['numberOfDays'],
      status: json['status'],
    );
  }
}
class ApiService {
   
  static const String baseUrl = 'http://185.131.54.8:5050/UserReg/leave-requests';

  static Future<List<LeaveRequest>> fetchLeaveRequests(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId')); // Send as string

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => LeaveRequest.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load leave requests");
    }
  }
}


class ViewLeaveRequestScreen extends StatefulWidget {
  final String userId; 

  const ViewLeaveRequestScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ViewLeaveRequestScreenState createState() => _ViewLeaveRequestScreenState();
}

class _ViewLeaveRequestScreenState extends State<ViewLeaveRequestScreen> {
  late Future<List<LeaveRequest>> _leaveRequests;


  @override
void initState() {
  super.initState();
  _leaveRequests = ApiService.fetchLeaveRequests(widget.userId); // Load directly
}


   void _loadLeaveRequests(String userId) {
    int parsedUserId = int.tryParse(userId)??0;
    setState(() {
      _leaveRequests = ApiService.fetchLeaveRequests(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Leave Requests')),
      body: FutureBuilder<List<LeaveRequest>>(
        future: _leaveRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading leave requests"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No leave requests found"));
          }

          List<LeaveRequest> leaveRequests = snapshot.data!;

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              LeaveRequest leave = leaveRequests[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${leave.leaveType} (${leave.status})"),
                  subtitle: Text("From: ${leave.fromDate} - To: ${leave.toDate}\nReason: ${leave.reason}"),
                  trailing: Text(
                    leave.status,
                    style: TextStyle(
                      color: leave.status == 'PENDING' ? Colors.orange :
                             leave.status == 'APPROVED' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
