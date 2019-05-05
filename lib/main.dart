import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  //sensor data
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;

  //location data
  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);
  List<double> _locationValues;

  //POST
  static final CREATE_POST_URL = 'http://192.168.1.248/data';
  String getTime() {
    return DateTime.now().toUtc().toString();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(3))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(2))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(3))
        ?.toList();
    final List<String> location =
        _locationValues?.map((double v) => v.toStringAsFixed(8))?.toList();

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
          Padding(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$location'),
                  ],
                ),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          RaisedButton(
            child: Text('Post Stuff'),
            onPressed: () async {
              Post newPost = new Post(
                  userId: 123,
                  sensorType: SensorType.gyro,
                  timeStamp: getTime(),
                  x: .123,
                  y: .123,
                  z: .123);
              String jsonBody = json.encode(newPost.toMap());
              Post p = await createSensorPost(CREATE_POST_URL, body: jsonBody);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // PermissionHandler()
    //     .checkPermissionStatus(PermissionGroup.location)
    //     .then(_updatePermission);
    //

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
              // Post newPost = new Post(
        //     userId: "123",
        //     sensorType: 'accelerometer',
        //     timeStamp: new DateTime.now(),
        //     x: event.x,
        //     y: event.y,
        //     z: event.z);
        // Post p = await createSensorPost(CREATE_POST_URL, body: newPost.toMap());
        // print(p.x);
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
    _streamSubscriptions.add(geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      setState(() {
        _locationValues = <double>[position.latitude, position.longitude];
        print("heelloo" + _locationValues[0].toString());
      });
    }));

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

  // void _updatePermission(PermissionStatus value) {
  //   print(value.toString());
  // }

  // void _askPermission() {
  //   PermissionHandler().requestPermissions([PermissionGroup.location]);

  //   PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.location)
  //       .then(_updatePermission);
  // }
}

//////// Sensor Post

class SensorType{
  static String accel = "accelerometer";
  static String useraccel = "useraccelerometer";
  static String gyro = "gyroscope";
  static String unknown = "unknown";
}

class Post {
  final int userId;
  final String sensorType;
  final String timeStamp;
  final double x;
  final double y;
  final double z;

  Post({this.userId, this.sensorType, this.timeStamp, this.x, this.y, this.z});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['user_id'],
      sensorType: SensorType.unknown,
      timeStamp: json['accelerometer']['timestamp'],
      x: json['accelerometer']['x'],
      y: json['accelerometer']['y'],
      z: json['accelerometer']['z'],
    );
  }

  factory Post.fromblankJson(Map<String, dynamic> json) {
    return Post(
      userId: 1,
      sensorType: SensorType.unknown,
      timeStamp: '23-32-41',
      x: 0.001,
      y: 0.002,
      z: 0.003,
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["user_id"] = userId;

    var databody = {};
    databody["timestamp"] = timeStamp;
    databody["x"] = x;
    databody["y"] = y;
    databody["z"] = z;

    map[sensorType.toString()] = [databody];
    return map;
  }
}

Future<Post> createSensorPost(String url, {String body}) async {
  print("this is dumb");
  final header = {'Content-Type': 'application/json'};
  return http
      .post(url, headers: header, body: body)
      .then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return Post.fromblankJson(json.decode(response.body));
  });
}

//////// Position Post stuff

class PositionPost {
  final String userid;
  final String longitude;
  final String latitude;
  final String timestamp;
  final String accuracy;
  final String altitude;
  final String heading;
  final String speed;
  final String speedaccuracy;

  PositionPost(
      {this.userid,
      this.longitude,
      this.latitude,
      this.timestamp,
      this.accuracy,
      this.altitude,
      this.heading,
      this.speed,
      this.speedaccuracy});

  factory PositionPost.fromJson(Map<String, dynamic> json) {
    return PositionPost(
        longitude: json["longitude"],
        latitude: json["latitude"],
        timestamp: json["timestamp"],
        accuracy: json["accuracy"],
        altitude: json["altitude"],
        heading: json["heading"],
        speed: json["speed"],
        speedaccuracy: json["speedaccuracy"]);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["user_id"] = userid;

    var databody = {};
    databody["user_id"] = userid;
    databody["longitude"] = longitude;
    databody["latitude"] = latitude;
    databody["timestamp"] = timestamp;
    databody["accuracy"] = accuracy;
    databody["altitude"] = altitude;
    databody["speed"] = speed;
    databody["speedacuracy"] = speedaccuracy;

    map["position"] = databody;
    return map;
  }
}

Future<Post> createPositionPost(String url, {Map body}) async {
  return http.post(url, body: body).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return Post.fromJson(json.decode(response.body));
  });
}
