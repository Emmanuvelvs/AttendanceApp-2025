import 'dart:async';
import 'dart:convert'; // For JSON encoding
import 'package:attendance_project_1/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


Future<String?> getid() async{
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

class Scanner extends StatefulWidget {
  final String type ;
 
  const Scanner({Key? key, required this.type}) : super(key: key);

  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State<Scanner> with WidgetsBindingObserver {
  late MobileScannerController controller;

  String val = "";

  String? userId;

late String backendUrl;

   String presentDate = "";
   String presentTime = "";
  // Replace with your backend URL
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _getid();

 backendUrl = widget.type.toLowerCase() == 'in'
        ? 'http://185.131.54.8:5050/UserReg/inScanQR'
        : 'http://185.131.54.8:5050/UserReg/outScanQR';
  }

Future<void>_getid() async{
  userId = await getid();
  if (userId == null){
    print('No user ID found. please login again');

  }
  print("Retrieved id: $userId");
  setState(() {});
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  controller.dispose(); // No `await` here
  super.dispose();
}


Future<Position?> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if(!serviceEnabled){
    print('Location services are disabled.');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied.');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied.');
    return null;
  }

  return await Geolocator.getCurrentPosition();
}
  // Function to send the scanned data to the backend
 Future<void> sendDataToBackend(String qrCode) async {
  if (userId == null) {
    print('Error: User ID is null.');

    await _showDialog(
      title: 'Error',
       message:'No user ID found. pleaselogin again.'
        );

    return;
  }
  
  try {

final Position? position = await _determinePosition();
    if (position == null) {
      await _showDialog(title: 'Error', message: 'Unable to get location.');
      return;
    }

    final String url = '$backendUrl?userId=$userId';

    final DateTime now = DateTime.now();
    final String presentDate = 
    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String presentTime = 
    "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final Map<String, dynamic> data = {
      "presentDate": presentDate,
      "presentTime": presentTime,
      "type": widget.type.toLowerCase(),
      "qr_code": qrCode,
      "user_id": userId,
      "action": widget.type,
      "timestamp": DateTime.now().toIso8601String(),
      "userLatitude": position.latitude.toString(),
      "userLongitude":position.longitude.toString(),
    };

    print('Sending data to backend: ${jsonEncode(data)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String message = responseBody['message'] ?? '';

      print('Data sent successfully: ${response.body}');
       
await _showDialogAndNavigateBack(
        title: 'Success',
        message: message,
      );

    } else {

      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      String errorMessage = errorBody['error'] ?? '';


      print('Failed to send data. Status: ${response.statusCode}');
      print('Response body: ${response.body}');

        await _showDialog(
        title: 'Error',
        message: errorMessage,
      );
 }
  } catch (e) {
    print('Error sending data: $e');
    await _showDialog(
      title: 'Error',
      message: 'An error occurred: $e',
    );
  }
}

Future<void> _showDialog({required String title, required String message}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> _showDialogAndNavigateBack(
    {required String title, required String message}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ScreenHome()),
                (route) => false,
              ); // Navigate to home and clear backstack
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('QR Scanner')),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          child: MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              String qrCode = '';
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                  qrCode = barcode.rawValue!;
                  break;
                }
              }

              // Handle the scanned QR code
              setState(() {
                val = qrCode;
              });
              print('Scanned QR Code: $qrCode');

              // Send the QR code data to the backend
              await sendDataToBackend(qrCode);

              // Stop scanning after one QR code is detected
              await controller.stop();
            },
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "scanned QR Code: $val",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            " type: ${widget.type}",
            style: TextStyle(fontSize: 16,),
          ),
        ),
      ],
    ),
  );
}



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(controller.start());
    } else if (state == AppLifecycleState.paused) {
      unawaited(controller.stop());
    }
  }
}

