import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import "acceralation.dart" as acc;
import 'package:http/http.dart' as http;
import 'post.dart';
import 'dart:convert';
import 'package:flutter_compass/flutter_compass.dart';

import 'package:vibration/vibration.dart';

import 'package:geolocator/geolocator.dart';


//足跡ページ
//location/update

int step_sum = 0;
int step_now = 0;
String name = 'user_1';

//TODO サーバからはお宝があった場合true,お宝がなかった場合false
//TODO trueの場合のファンクションを考える


class StepPage extends StatefulWidget {

  @override
  _StepPageState createState() => _StepPageState();
}

class _StepPageState extends State<StepPage> {

  int distance = 99999;
  bool get = false;
  double _direction;

  acc.Acceralation acceralation;
  List<acc.Acceralation> acceralation_list = [];

  List<double> _gyroscopeValues;

  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];

  //x,y,z xは縦軸，yは横軸，zは奥行き
  //gyro : デバイスの回転を示す

  AnimationController _controller;

  Position position;

  @override
  void initState() {
    super.initState();
    print("init start");
    getacceralation();
    Timer.periodic(Duration(milliseconds: 500), getStep);
    Timer.periodic(Duration(milliseconds: 500), UserStepRequest);
    _vibrate();
    FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
        debugPrint("$_direction");
      });
    });
    _getLocation(context);

  }

  @override
  Widget build(BuildContext context) {
    final List<String> gyroscopemeter = _gyroscopeValues?.map((double v) =>
        v.toStringAsFixed(1))?.toList();
    final String gyro_x = _gyroscopeValues[0].toStringAsFixed(2);
    final String gyro_y = _gyroscopeValues[1].toStringAsFixed(2);

    debugPrint("$position");

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(50)),

                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(30)),

                    Container(
                        child: Image.asset("lib/images/step.png",
                          height: 100,
                          width: 100,
                          fit: BoxFit.fitWidth,)
                    ),

                    Padding(padding: EdgeInsets.all(10)),

                    Text("歩数 : ${step_sum}",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),


                Padding(padding: EdgeInsets.all(30)),

                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(30)),

                    Container(
                        child: Image.asset("lib/images/tresure.jpg",
                          height: 100,
                          width: 100,
                          fit: BoxFit.fitWidth,)
                    ),

                    Padding(padding: EdgeInsets.all(10)),

                    Text("お宝までの距離 : ${distance}",
                      style: TextStyle(fontSize: 18),),
                    //TODO  distanceが近いときに通知する
                  ],
                ),

                Padding(padding: EdgeInsets.all(30)),

                Text("current_location : ${position}",
                style: TextStyle(fontSize: 18),),


              ],
            ),
          ),
        )
    );
  }

  //positionにcurrentlocation内臓されている

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void getacceralation(){
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        acceralation = acc.Acceralation(event.x, event.y, event.z);
        acceralation_list.add(acceralation);
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
  }


  void getStep(Timer timer){
    step_now = acc.getStep(acceralation_list);
    step_sum += step_now;
    acceralation_list.clear();
  }

  void _vibrate(){
    if (distance == 0) {
      Vibration.vibrate();
    }
  }

  Future<void> _getLocation(context) async {
    Position _currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している
    print(_currentPosition);
    setState(() {
      position = _currentPosition;
    });
  }

}


Future<Post> fetchPost() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

//TODO ngrokは更新される

void UserRegistRequest() async {
  String url = "http://e739fe18.ngrok.io/location/update";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':'user_1','x':3,'y':4,'step':1});
  http.Response resp = await http.post(url, headers: headers, body: body);

  if (resp.statusCode != 200) {
    return;
  }
//  print(json.decode(resp.body));
//  print(resp.body);
}


//これでサーバにデータを送信
void UserStepRequest(Timer timer) async {
  String url = "http://e739fe18.ngrok.io/location/update";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':name,'step':step_now});
  http.Response resp = await http.post(url, headers: headers, body: body);
  if (resp.statusCode != 200) {
    return;
  }
  print(json.decode(resp.body));
//  print(resp.body);
}


