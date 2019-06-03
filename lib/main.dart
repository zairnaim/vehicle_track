import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

final CREATE_POST_URL = 'http://api.allegoryinsurance.com/data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      //home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: BackgroundGeo(),
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
  static final CREATE_POST_URL = 'http://api.allegoryinsurance.com/data';
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
                      'Location',
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
        PositionPost pp = PositionPost(
          userid: 123,
          accuracy: position.accuracy,
          altitude: position.altitude,
          timestamp: position.timestamp.toUtc().toString(),
          longitude: position.longitude,
          latitude: position.latitude,
          heading: position.heading,
          speed: position.speed,
          speedaccuracy: position.speedAccuracy,
        );
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

class SensorType {
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
  final int userid;
  final double longitude;
  final double latitude;
  final String timestamp;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedaccuracy;

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
    databody["timestamp"] = timestamp;
    databody["latitude"] = latitude;
    databody["longitude"] = longitude;
    databody["accuracy"] = accuracy;
    databody["altitude"] = altitude;
    databody["heading"] = 0;
    databody["speed"] = speed;
    databody["speed_accuracy"] = 0;

    map["position"] = [databody];
    return map;
  }
}

Future<PositionPost> createPositionPost(String url, {String body}) async {
  print("this is dumb");
  final header = {'Content-Type': 'application/json'};
  return http
      .post(url, headers: header, body: body)
      .then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return PositionPost.fromJson(json.decode(response.body));
  });
}

///// Flutter Background Geolocation Plugin Stuff

class BackgroundGeo extends StatefulWidget {
  @override
  _BackgroundGeoState createState() => _BackgroundGeoState();
}

class _BackgroundGeoState extends State<BackgroundGeo> {
  @override
  void initState() {
    //https://gist.github.com/christocracy/a0464846de8a9c27c7e9de5616082878
    super.initState();
    ////
    // 1.  Listen to events (See docs for all 12 available events).
    //

    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation(_onLocation);

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange(_onLocation);

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 1.0,
            stopOnTerminate: false,
            startOnBoot: true,
            debug: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE,
            reset: true))
        .then((bg.State state) {
      if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
      }
    });
  }

  String str = "";
  void _onLocation(bg.Location location) async {
    print('[location] - $location');

    String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);

    setState(() {
      str = location.timestamp;
    });

    //   _locationValues = <double>[position.latitude, position.longitude];
    //print("heelloo" + _locationValues[0].toString());
    PositionPost pp = PositionPost(
      userid: 123,
      accuracy: location.coords.accuracy,
      altitude: location.coords.altitude,
      timestamp: location.timestamp.toString(),
      longitude: location.coords.longitude,
      latitude: location.coords.latitude,
      heading: location.coords.heading,
      speed: location.coords.speed,
      speedaccuracy: 0,
    );

    String jsonBody = json.encode(pp.toMap());
    PositionPost p = await createPositionPost(CREATE_POST_URL, body: jsonBody);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(str),
          RaisedButton(
            child: Text("get the data"),
            onPressed: _onClickGetCurrentPosition,
          ),
        ],
      ),
    );
  }

  void _onClickGetCurrentPosition() {
    bg.BackgroundGeolocation.getCurrentPosition(
            persist: false, // <-- do not persist this location
            desiredAccuracy: 0, // <-- desire best possible accuracy
            timeout: 30000, // <-- wait 30s before giving up.
            samples: 1 // <-- sample 3 location before selecting best.
            )
        .then((bg.Location location) {
      print('[getCurrentPosition] - $location');
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
  }
}
