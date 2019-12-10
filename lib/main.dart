import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ACCELEROMETER AND GYROSCOPE Page'),
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

  List<double> _accelerometerValues;
  List<double> _gyroscopeValues;

  List<StreamSubscription<dynamic>> _streamSubscriptions = <
      StreamSubscription<dynamic>>[];

  //x,y,z xは縦軸，yは横軸，zは奥行き
  //gyro : デバイスの回転を示す

  @override
  Widget build(BuildContext context) {

    final List<String> accelerometer = _accelerometerValues?.map((double v) =>
        v.toStringAsFixed(1))?.toList();
    final double accel_x = _accelerometerValues[0];
    final String accel_y = _accelerometerValues[1].toStringAsFixed(2);

    final List<String> gyroscopemeter = _gyroscopeValues?.map((double v) =>
        v.toStringAsFixed(1))?.toList();
    final double gyro_x = _gyroscopeValues[0];
    final String gyro_y = _gyroscopeValues[1].toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('Accelerometer: $accelerometer',
                style: TextStyle(fontSize: 15),
              ),
              Padding(padding: EdgeInsets.all(15)),

              Text('ACCEL_X: $accel_x',
                style: TextStyle(fontSize: 15),
              ),

              Padding(padding: EdgeInsets.all(15)),

              Text("ACCEL_Y: $accel_y",
                style: TextStyle(fontSize: 15),
              ),

              Padding(padding: EdgeInsets.all(15)),

              Text("GYRO_X: $gyro_x",
                style: TextStyle(fontSize: 15),
              ),

              Padding(padding: EdgeInsets.all(15)),

              Text("GYRO_Y: $gyro_y",
                style: TextStyle(fontSize: 15),
              ),

              Padding(padding: EdgeInsets.all(15)),

              Text("GYROSCOPEMETER: $gyroscopemeter",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

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
  }
}