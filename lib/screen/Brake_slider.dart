import 'dart:ffi';

import 'package:attendance_project_1/screen/Brake_Scanner.dart';
import 'package:flutter/material.dart';

class BrakeSlider extends StatefulWidget {
  const BrakeSlider({Key? key}) : super(key: key);

  @override
  _BrakeSliderState createState() => _BrakeSliderState();
}

class _BrakeSliderState extends State<BrakeSlider> {
  double _slidePosition = 250.0; // Start at the right side (OUT)
  bool _isActive = true; // Start with "Slide for IN"

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _slidePosition += details.delta.dx;
      _slidePosition = _slidePosition.clamp(0.0, 250.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_slidePosition < 100) {
        // Move left (IN)
        _slidePosition = 0.0;
        _isActive = false;
        _navigateToBreakScanner("in");
      } else {
        // Move back to right (OUT)
        _slidePosition = 250.0;
        _isActive = true;
        _navigateToBreakScanner("out");
      }
    });
  }


void _navigateToBreakScanner(String type) {
    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreakScanner(type: type)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brake Slider'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Use The Brake Slider'),
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
                    border: Border.all(color: Colors.grey),
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
                           
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _isActive ? 'Slide for IN' : 'Slide for OUT',
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
            ],
          ),
        ),
      ),
    );
  }
}
