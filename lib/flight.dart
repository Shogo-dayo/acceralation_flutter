import 'package:acceralation_flutter/main.dart';
import "package:flutter/material.dart";


class FlightPage extends StatefulWidget {
  @override
  FlightPageState createState() => FlightPageState();
}

class FlightPageState extends State<FlightPage> {

  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  //globalkey でformの入力を行う

  final _Key = GlobalKey<State>();

  // init the step to 0th position
  int current_step = 0;

  //TODO currentstepの状態で足跡を制御する.

  List<Step> my_steps = [
    Step(
      // Title of the Step
        title: Text("空港に向かっていますか"),
        // Content, it can be any widget here. Using basic Text for this example
        content: Text("", style: TextStyle(fontSize: 12),),
        isActive: true,),
    Step(
        title: Text("あなたはチェックインを終えましたか"),
        content: Text("",style: TextStyle(fontSize: 12)),
        // You can change the style of the step icon i.e number, editing, etc.
        isActive: true),
    Step(
        title: Text("あなたは検査を終えましたか"),
        content: Text("",style: TextStyle(fontSize: 12)),
        isActive: true),
    Step(
        title: Text("搭乗しましたか"),
        content: Text("",style: TextStyle(fontSize: 12)),
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
                          left: 45.0, right: 25.0, top: 10.0),
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
                      )),

                  !_status ? _getActionButtons() : Container(),
                ],
              ),
            ),
          ),



          Column(
            children: <Widget>[
              Container(
                alignment: Alignment(-0.7,0.3),
                child : Text("Your Flight Step",style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
                ),
              ),

              Stepper(
                // Using a variable here for handling the currentStep
                currentStep: this.current_step,
                // List the steps you would like to have
                steps: my_steps,
                // Define the type of Stepper style
                // StepperType.horizontal :  Horizontal Style
                // StepperType.vertical   :  Vertical Style
                type: StepperType.vertical,
                // Know the step that is tapped
                onStepTapped: (step) {
                  // On hitting step itself, change the state and jump to that step
                  setState(() {
                    // update the variable handling the current step value
                    // jump to the tapped step
                    current_step = step;

                    //TODO ここで現時点でのステップをサーバに送る



                  });
                  // Log function call
                  print("onStepTapped : " + step.toString());
                },


                onStepCancel: () {
                  // On hitting cancel button, change the state
                  setState(() {
                    // update the variable handling the current step value
                    // going back one step i.e subtracting 1, until its 0
                    if (current_step > 0) {
                      current_step = current_step - 1;
                    } else {
                      current_step = 0;
                    }
                  });
                  // Log function call
                  print("onStepCancel : " + current_step.toString());
                },
                // On hitting continue button, change the state


                onStepContinue: () {
                  setState(() {
                    // update the variable handling the current step value
                    // going back one step i.e adding 1, until its the length of the step
                    if (current_step < my_steps.length - 1) {
                      current_step = current_step + 1;
                    } else {
                      current_step = 0;
                    }
                  });
                  // Log function call
                  print("onStepContinue : " + current_step.toString());
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