import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';
import 'package:xiaomi_scale_example/raw_data_pane.dart';
import 'util/permissions.dart';

class Measure extends StatefulWidget {
  @override
  _MeasureState createState() => _MeasureState();
}

class _MeasureState extends State<Measure> {
  Map<String, MiScaleMeasurement> measurements = {}; // <Id, Measurement>
  final _scale = MiScale.instance;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
      child: Scaffold(
      body: Column(
          children: <Widget>[
            Padding(
            padding: const EdgeInsets.only(top: 105),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/plastic');
                    }, // handle your image tap here
                    child: Image.asset(
                      "assets/plastic.png",
                      height: 120,
                    ),
                  ),
                  GestureDetector(

                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/glass');
                    }, // handle your image tap here
                    child: Image.asset(
                      "assets/glass.png",
                      height: 120,
                    ),
                  ),
                ]

            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/paper');
                    }, // handle your image tap here
                    child: Image.asset(
                      "assets/paper.png",
                      height: 120,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/organic');
                    }, // handle your image tap here
                    child: Image.asset(
                      "assets/organic.png",
                      height: 120,
                    ),
                  ),
                ]
            ),
          )

        ],
        ),
      )
    );

  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vous êtes sûrs ?', textAlign: TextAlign.center,),
        content: const Text("Voulez vous quitter l'application ?", textAlign: TextAlign.center,),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 110.0),
            child: GestureDetector(
              onTap: () => exit(0),
              child: const Text('OUI'),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(right: 47.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: const Text('NON'),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
}