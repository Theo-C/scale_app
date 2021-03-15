import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'option.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

import 'controller/form_controller.dart';
import 'model/feedback_form.dart';
import 'util/permissions.dart';

class Plastic extends StatefulWidget {
  @override
  _PlasticState createState() => _PlasticState();
}

class _PlasticState extends State<Plastic> {
  StreamSubscription _measurementSubscription;
  Map<String, MiScaleMeasurement> measurements = {}; // <Id, Measurement>
  final _scale = MiScale.instance;
  String measure;
  String wasteType = 'plastic';
  String idCanteen = OptionState.id;
  String nameCanteen = OptionState.name;

  void testForm(){
    idCanteen ??= '272712';
    nameCanteen ??= 'DouaiTest1';
  }


  @override
  void dispose() {
    super.dispose();
    stopTakingMeasurements(dispose: true);
  }


  Future<void> startTakingMeasurements() async {
    // Make sure we have locatin required for BLE scanning
    if (!await checkPermission()) return;
    // Start taking measurements
    setState(() {
      _measurementSubscription = _scale.takeMeasurements().listen(
            (measurement) {
          setState(() {
            measurements[measurement.id] = measurement;
          });
        },
        onError: (e) {
          print(e);
          stopTakingMeasurements();
        },
        onDone: stopTakingMeasurements,

      );
    });
  }

  void stopTakingMeasurements({dispose = false}) {
    _measurementSubscription?.cancel();
    _measurementSubscription = null;
    if (!dispose) setState(() {});
  }

  void _submitForm(MiScaleMeasurement measurement) {
    testForm();
      var feedbackForm = FeedbackForm(
          idCanteen,
          nameCanteen,
          measure.substring(0, measure.length - 2),
          wasteType,
          measurement.dateTime.toString(),
      );

      var formController = FormController((String res) {
        print('Response = $res');
      });

      formController.submitForm(feedbackForm);
    }

     moveToLastScreen() {
    Navigator.popAndPushNamed(context, '/home');
    }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return moveToLastScreen();
        },
        child:Scaffold(
            appBar: AppBar(
              title: Text('Pesage de plastique'),
              centerTitle: true,
              backgroundColor: Colors.red[800],
            ),
            body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          child: Image.asset(
                            "assets/plastic.png",
                            height: 100,
                          ),
                        ),
                      ],

                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: const Text('Lancer le pesage'),
                        onPressed: _measurementSubscription == null ? startTakingMeasurements : null,
                      ),
                      ElevatedButton(
                        child: const Text('Arrêter le pesage'),
                        onPressed: _measurementSubscription != null ? stopTakingMeasurements : null,

                      ),
                    ],

                  ),
                  Opacity(
                    opacity: _measurementSubscription != null ? 1 : 0,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: measurements.values.map(_buildMeasurementWidget).toList(),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FloatingActionButton(
                            heroTag: "btn1",
                            onPressed:()=>[Navigator.pushReplacementNamed(context, '/home'),
                              Fluttertoast.showToast(
                                  msg: "Mesure validée",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              ), _submitForm(MiScaleMeasurement())],

                            child:
                            Image.asset('assets/validate.png', height: 43)
                        ),


                        FloatingActionButton(
                            heroTag: "btn2",
                            onPressed:()=>[Navigator.pushReplacementNamed(context, '/home'),
                              Fluttertoast.showToast(
                                  msg: "Mesure invalidée",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              )],

                            child:
                            Image.asset('assets/cross.png', height: 43)
                        ),
                      ],

                    ),
                  ),


                ]
            )
        ),

       );

  }

  Widget _buildMeasurementWidget(MiScaleMeasurement measurement) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    measure = measurement.weight.toStringAsFixed(2) + " " +  measurement.unit.toString().split('.')[1],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40.0,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    measurement.stage.toString().split('.')[1],
                  ),

                ],
              ),

            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Cancel the measurement if it is still active
                if (measurement.isActive) _scale.cancelMeasurement(measurement.deviceId);
                // Remove the measurement from the list
                setState(() {
                  measurements.remove(measurement.id);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
