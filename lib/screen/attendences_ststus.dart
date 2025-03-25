import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


Future<List<Attendance>> fetchAttendance() async {
  final response = await http.get(Uri.parse('http://103.247.19.200:5050/UserReg/attendance/today'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Attendance.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load attendance data');
  }
}


class Attendance {
  final int id;
  final int userId;
  final String userName;
  final String batchType;
  final String attendanceDate;
  final String? scanInTime;
  final String? scanOutTime;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.userName,
    required this.batchType,
    required this.attendanceDate,
    this.scanInTime,
    this.scanOutTime,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      batchType: json['batchType'],
      attendanceDate: json['attendanceDate'],
      scanInTime: json['scanInTime'],
      scanOutTime: json['scanOutTime'],
      status: json['status'],
    );
  }
}



class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Status'),
      ),
      body: FutureBuilder<List<Attendance>>(
        future: fetchAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance data available.'));
          }

          final attendanceList = snapshot.data!;
          return ListView.builder(
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('${attendance.userName} (${attendance.batchType})'),
                  subtitle: Text(
                      'Date: ${attendance.attendanceDate}\nStatus: ${attendance.status}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('In: ${attendance.scanInTime ?? 'N/A'}'),
                      Text('Out: ${attendance.scanOutTime ?? 'N/A'}'),
                    ],
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
