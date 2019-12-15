import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

//phaseページ
//location/phase
String name;


class PhasePage extends StatefulWidget {
  @override
  PhasePageState createState() => PhasePageState();
}

class PhasePageState extends State<PhasePage> {

  bool _status = true;
  final FocusNode myFocusNode = FocusNode();


  // init the step to 0th position
  int current_phase = 0;
  final _key = GlobalKey<State>();





  //TODO currentstepの状態で足跡を制御する.
  //TODO サーバにnameとcurrent_stepを送る
  //TODO ngrokは更新される



  List<Step> my_steps = [
    Step(
      // Title of the Step
      title: Text("空港に向かっていますか"),
      // Content, it can be any widget here. Using basic Text for this example
      content: Text("", style: TextStyle(fontSize: 10),),
      isActive: true,),
    Step(
        title: Text("あなたはチェックインを終えましたか"),
        content: Text("", style: TextStyle(fontSize: 10)),
        // You can change the style of the step icon i.e number, editing, etc.
        isActive: true),
    Step(
        title: Text("あなたは検査を終えましたか"),
        content: Text("", style: TextStyle(fontSize: 10)),
        isActive: true),
    Step(
        title: Text("搭乗しましたか"),
        content: Text("", style: TextStyle(fontSize: 10)),
        isActive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      body: Column(
        children: <Widget>[
          Container(
            color: Color(0xffFFFFFF),
            child: Padding(
              padding: EdgeInsets.only(bottom: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(
                          left: 45.0, right: 25.0, top: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Your Flight Information',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _status ? _getEditIcon() : Container(),
                            ],
                          )
                        ],
                      )),

                  Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Enter Flight Date and Time",
                              ),
                              enabled: !_status,
                              autofocus: !_status,

                            ),
                          ),
                        ],
                      ),
                  ),

                  !_status ? _getActionButtons() : Container(),
                ],
              ),
            ),
          ),


          Column(
            children: <Widget>[
              Container(
                alignment: Alignment(-0.7, 0.3),
                child: Text("Your Flight Phase", style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
                ),
              ),

              Stepper(
                // Using a variable here for handling the currentStep
                currentStep: this.current_phase,
                // List the steps you would like to have
                steps: my_steps,
                // Define the type of Stepper style
                // StepperType.horizontal :  Horizontal Style
                // StepperType.vertical   :  Vertical Style
                type: StepperType.vertical,
                // Know the step that is tapped
                onStepTapped: (step) {
                  // On hitting step itself, change the state and jump to that step
                    // update the variable handling the current step value
                    // jump to the tapped step
                    current_phase = step;

                    UserPhaseRequest(current_phase);

                },


                onStepCancel: () {
                  // On hitting cancel button, change the state
                  setState(() {
                    // update the variable handling the current step value
                    // going back one step i.e subtracting 1, until its 0
                    if (current_phase > 0) {
                      current_phase = current_phase - 1;
                    } else {
                      current_phase = 0;
                    }
                  });

                  //TODO ここで,現時点でのステップをサーバに送る
                  UserPhaseRequest(current_phase);

                },
                // On hitting continue button, change the state


                onStepContinue: () {
                  setState(() {
                    // update the variable handling the current step value
                    // going back one step i.e adding 1, until its the length of the step
                    if (current_phase < my_steps.length - 1) {
                      current_phase = current_phase + 1;
                    } else {
                      current_phase = 0;
                    }
                  });

                  //TODO ここで,現時点でのステップをサーバに送る
                  UserPhaseRequest(current_phase);

                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: RaisedButton(
                    child: Text("Save"),
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: RaisedButton(
                    child: Text("Cancel"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}


//これでサーバにデータを送信
void UserPhaseRequest(int current_phase) async {
//  debugPrint("Current_Phase : ${current_phase}");
  if(name == null) return;
  String url = "http://38d14120.ngrok.io/location/phase";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':name,'current_phase':current_phase});
  http.Response resp = await http.post(url, headers: headers, body: body);
  if (resp.statusCode != 200) {
    return;
  }


  //print(json.decode(resp.body));
//  print(resp.body);
}

void SetUserNameInFlight(String username){
  name = username;
  print("User name is set ${name} in flight");
}
