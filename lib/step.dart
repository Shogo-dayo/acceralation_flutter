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
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


//足跡ページ
//location/update

int step_sum = 0;
int step_now = 0;
String name;
double _direction;
int tresure_distance;
bool tresure_bool;
double positionLat ;
double positionLon ;

double currentLat = 34.215247;
double currentLon = 134.018517;

double north = 45.0;
double west = 135.0;
double south = 225.0;
double east = 315.0;

double airport_lat = 34.215207;
double airport_lon = 135.018567;

double between_distance;



Map<String, dynamic> tresure_info;

AudioPlayer audioPlugin = AudioPlayer();

//TODO サーバからはお宝があった場合true,お宝がなかった場合false
//TODO trueの場合のファンクションを考える


class StepPage extends StatefulWidget {

  @override
  _StepPageState createState() => _StepPageState();
}

class _StepPageState extends State<StepPage> {

  bool get = false;

  acc.Acceralation acceralation;
  List<acc.Acceralation> acceralation_list = [];

  List<double> _gyroscopeValues;

  List<StreamSubscription<dynamic>> _streamSubscriptions = <
      StreamSubscription<dynamic>>[];

  AnimationController _controller;

  Position position;

  Map data;



  @override
  void initState() {
    super.initState();
    print("init start");
    getacceralation();

    //現在地取得
    _getLocation(context);

    //現在地と空港の距離算出
    calucalateDistance();
    //バイブレーション機能
    _vibrate();

    Timer.periodic(Duration(milliseconds: 1000), getStep);
    Timer.periodic(Duration(milliseconds: 1000), UserStepRequest);

  }

  @override
  Widget build(BuildContext context) {
    final List<String> gyroscopemeter = _gyroscopeValues?.map((double v) =>
        v.toStringAsFixed(1))?.toList();
    final String gyro_x = _gyroscopeValues[0].toStringAsFixed(2);
    final String gyro_y = _gyroscopeValues[1].toStringAsFixed(2);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(title: Text("Dowsing Start"),backgroundColor: Colors.blue,),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(50)),

              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(30)),

                  Container(
                      child: Image.asset("lib/images/step.png",
                        height: 110,
                        width: 110,
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
                        height: 110,
                        width: 110,
                        fit: BoxFit.fitWidth,)
                  ),

                  Padding(padding: EdgeInsets.all(10)),

                  Text("お宝までの距離 : ${tresure_distance}",
                    style: TextStyle(fontSize: 18),),
                  //TODO  distanceが近いときに通知する
                ],
              ),

              Padding(padding: EdgeInsets.all(30)),

//              Text("current_location : ${position}",
//                style: TextStyle(fontSize: 18),),
            ],
          ),
        ),
      ),
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

  void getacceralation() {
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
    _streamSubscriptions.add(FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;

        if (tresure_bool == true) {
          createDialog();
          return;

        } else
          return;


      });
    }));
  }


  void getStep(Timer timer) {
    step_now = acc.getStep(acceralation_list);
    step_sum += step_now;
    acceralation_list.clear();
  }

  void _vibrate(){
    if (tresure_bool == true) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> _getLocation(context) async {
    Position _currentPosition = await Geolocator()
        .getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している

    setState(() {
      position = _currentPosition;
      positionLat = position.latitude;
      positionLon = position.longitude;

    });
  }


  Future<void> calucalateDistance() async {
    http.Response response = await http.get("https://api.ekispert.jp/v1/json/search/course/plain?key=eBBWPyXMYduCN759&from=${positionLat},${positionLon},wgs84&to=${airport_lat},${airport_lon},wgs84");
    data = json.decode(response.body);
    between_distance = data["object"]["ResultSet"]["Course"][0]["Route"]["distance"];
    print("get body : $data");
    print("get between : $between_distance");

  }

  void createDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          CupertinoAlertDialog(
            title: Text("お宝get！！！！！！！！"),
            content: Text(""),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("ファストパスゲットだぜ"),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
            ],
          ),
    );
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
  String url = "http://ed2715b6.ngrok.io/location/update";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':'user_1','x':3,'y':4,'step':1});
  http.Response resp = await http.post(url, headers: headers, body: body);

  if (resp.statusCode != 200) {
    return;
  }
//  print(json.decode(resp.body));
//  print(resp.body);
}


//これでサーバにユーザのstepデータを送信
void UserStepRequest(Timer timer) async {
  if(name == null) return;
  String url = "http://ed2715b6.ngrok.io/location/update";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':name,'step':step_now, "direction" : getDirection(_direction)});
  http.Response resp = await http.post(url, headers: headers, body: body);
  if (resp.statusCode != 200) {
    return;
  }
//  print(json.decode(resp.body));


  tresure_info = json.decode(resp.body);
  tresure_distance = tresure_info["distance"];
  tresure_bool = tresure_info["isTreasure"];
  print("Tresure_Distance : $tresure_distance");

  if(tresure_distance > 500) callFar();
  else if(tresure_distance > 350) callSoso();
  else callNear();

}

void SetUserNameInMap(String username){
  name = username;
  print("User name is set ${name} in flight");
}

String getDirection(double dir){
  if(north <= dir && dir < west) return "n";
  else if(west <= dir && dir < south) return "w";
  else if(south <= dir && dir < east) return "s";
  else return "e";
}

void callNear() {
  FlutterRingtonePlayer.playNotification(volume:100 , looping:false);
}

void callSoso() {
  FlutterRingtonePlayer.playNotification(volume:10 , looping:false);
}

void callFar() {
  FlutterRingtonePlayer.playNotification(volume:0.1 , looping:false);

}