import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
// import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  //sensor data
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;

  //location data
  // var geolocator = Geolocator();
  // var locationOptions =
  //     LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  // List<double> _locationValues;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(3))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(3))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(3))
        ?.toList();
    // final List<String> location = _locationValues
    //     ?.map((double v) => v.toStringAsFixed(3))
    //     ?.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Tracker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Accelerometer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$accelerometer')
                  ],
                ),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'UserAccelerometer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$userAccelerometer'),
                  ],
                ),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Gyroscope',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$gyroscope'),
                  ],
                ),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          // Padding(
          //   child: Card(
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: <Widget>[
          //           Text(
          //             'location',
          //             style: TextStyle(fontWeight: FontWeight.bold),
          //           ),
          //           Text('$location'),
          //         ],
          //       ),
          //     ),
          //   ),
          //   padding: const EdgeInsets.all(16.0),
          // ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    // _streamSubscriptions.add(geolocator
    //     .getPositionStream(locationOptions)
    //     .listen((Position position) {
    //   setState(() {
    //     _locationValues = <double>[position.latitude, position.longitude];
    //   });
    // }));

    // StreamSubscription<Position> positionStream = geolocator
    //     .getPositionStream(locationOptions)
    //     .listen((Position _position) {
    //   print(_position == null
    //       ? 'Unknown'
    //       : _position.latitude.toString() +
    //           ', ' +
    //           _position.longitude.toString());
    // });
  }
}
