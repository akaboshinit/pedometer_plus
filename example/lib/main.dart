import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  final _pedometer = Pedometer();
  PedestrianStatus _status = PedestrianStatus.unknown;
  int _streamedStepCount = 0;
  int _stepCounts = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(int step) {
    print(step);
    setState(() {
      _streamedStepCount = step;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus status) {
    print(status);
    setState(() {
      _status = status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    print('Pedestrian Status not available');
    setState(() {
      _status = PedestrianStatus.unknown;
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    print('Step Count not available');
    setState(() {
      _streamedStepCount = 0;
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    _pedometer
        .stepCountStreamFrom(from: todayStart)
        .listen(onStepCount)
        .onError(onStepCountError);

    _getStepCount();

    if (!mounted) return;
  }

  Future<void> _getStepCount() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final stepCounts = await _pedometer.getStepCount(
      from: todayStart,
      to: DateTime.now(),
    );

    setState(() {
      _stepCounts = stepCounts;
    });
    print('Step Count: $_stepCounts');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Stream Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _streamedStepCount.toString(),
                style: TextStyle(fontSize: 60),
              ),
              Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _stepCounts.toString(),
                style: TextStyle(fontSize: 60),
              ),
              TextButton(
                onPressed: _getStepCount,
                child: Text('Get Step Count'),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian Status',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _status == PedestrianStatus.walking
                    ? Icons.directions_walk
                    : _status == PedestrianStatus.stopped
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status.name,
                  style: _status == PedestrianStatus.walking ||
                          _status == PedestrianStatus.stopped
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
