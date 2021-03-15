import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';
import 'controller/form_controller.dart';
import 'model/feedback_form.dart';
import 'util/permissions.dart';

class Option extends StatefulWidget {
  @override
  OptionState createState() => OptionState();
}

class OptionState extends State<Option> {
  StreamSubscription _scanSubscription;
  Map<String, MiScaleDevice> devices = {}; // <Id, MiScaleDevice>
  final _scale = MiScale.instance;
  static String id;
  static String name;

  @override
  void dispose() {
    stopDiscovery(dispose: true);
    super.dispose();
  }

  Future<void> startDiscovery() async {
    // Make sure we have location permission required for BLE scanning
    if (!await checkPermission()) return;
    // Clear device list
    devices = {};
    // Start scanning
    setState(() {
      _scanSubscription = _scale.discoverDevices().listen(
            (device) {
          print(device);
          setState(() {
            devices[device.id] = device;
          });
        },
        onError: (e) {
          print(e);
          stopDiscovery();
        },
        onDone: stopDiscovery,
      );
    });
  }

  void stopDiscovery({dispose = false}) {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!dispose) setState(() {});
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
 TextEditingController idController = TextEditingController();
 TextEditingController nameController = TextEditingController();

  void _submitForm(MiScaleMeasurement measurement) {

    if (_formKey.currentState.validate()) {
      var feedbackForm = FeedbackForm(
        '',
        '',
        '',
        '',
          ''
      );

      var formController = FormController((String res) {
        print('Response = $res');
      });

      formController.submitForm(feedbackForm);
    }
  }

  moveToLastScreen() {
    Navigator.pushReplacementNamed(context, '/measure');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope (
        onWillPop: () {
          return moveToLastScreen();
        },
      child: Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: idController,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "L'identifiant ne peut pas être vide";
                        } else if (value.length < 5) {
                          return "L'identifiant doit contenir au moins 5 numéros";
                        }
                        id = value;
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Id',
                        hintText: 'Identifiant de la cantine',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: nameController,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Le nom ne peut pas être vide";
                        }
                        name = value;
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        hintText: 'Nom de la cantine',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: FloatingActionButton(
                onPressed:()=>[
                  Fluttertoast.showToast(
                      msg: "Informations enregistrées",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0
                  ),
                  _submitForm(MiScaleMeasurement()),
                  FocusScope.of(context).unfocus()
                ],

                child: Image.asset(
                  "assets/validate.png", height: 43 ,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text('Lancer le scan'),
                    onPressed: _scanSubscription == null ? startDiscovery : null,
                  ),
                  ElevatedButton(
                    child: const Text('Arrêter le scan'),
                    onPressed: _scanSubscription != null ? stopDiscovery : null,
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: _scanSubscription != null ? 1 : 0,
              child: const Center(child: CircularProgressIndicator()),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: devices.values.map(_buildDeviceWidget).toList(),
                ),
              ),
            ),
          ],
        ),

      ),

    )
    );
  }

  Widget _buildDeviceWidget(MiScaleDevice device) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nom: ${device.name}'),
                  Text("Identifiant de l'appareil : ${device.id}"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('RSSI: ${device.rssi}dBm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
