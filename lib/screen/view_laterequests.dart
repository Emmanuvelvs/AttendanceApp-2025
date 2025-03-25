import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


class LateRequest {
  final int id;
  final int userId;
  final String reason;
  final String date;
  final int batchId;
  final String status;

  LateRequest({
    required this.id,
    required this.userId,
    required this.reason,
    required this.date,
    required this.batchId,
    required this.status,
  });

  factory LateRequest.fromJson(Map<String, dynamic> json) {
    return LateRequest(
      id: json['id'],
      userId: json['userId'],
      reason: json['reason'],
      date: json['date'],
      batchId: json['batchId'],
      status: json['status'],
    );
  }
}


class LateRequestService {
  static Future<List<LateRequest>> fetchLateRequests(int userId) async {
    final response = await http.get(
      Uri.parse('http://103.247.19.200:5050/UserReg/late-requests?userId=$userId'), 
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((json) => LateRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load late requests');
    }
  }
}


class LateRequestScreen extends StatefulWidget {
  final int userId;

  LateRequestScreen({required this.userId});

  @override
  _LateRequestScreenState createState() => _LateRequestScreenState();
}

class _LateRequestScreenState extends State<LateRequestScreen> {
  late Future<List<LateRequest>> futureLateRequests;

  @override
  void initState() {
    super.initState();
    futureLateRequests = LateRequestService.fetchLateRequests(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Late Requests")),
      body: FutureBuilder<List<LateRequest>>(
        future: futureLateRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No late requests found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                LateRequest lateRequest = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text("Status: ${lateRequest.status}"),
                    subtitle: Text("Reason: ${lateRequest.reason}\nDate: ${lateRequest.date}"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
