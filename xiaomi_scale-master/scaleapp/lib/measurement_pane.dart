import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';
import 'package:xiaomi_scale_example/raw_data_pane.dart';
import 'util/permissions.dart';

class MeasurementPane extends StatefulWidget {
  @override
  _MeasurementPaneState createState() => _MeasurementPaneState();
}

class _MeasurementPaneState extends State<MeasurementPane> {
  StreamSubscription _measurementSubscription;
  Map<String, MiScaleMeasurement> measurements = {}; // <Id, Measurement>
  final _scale = MiScale.instance;

  @override
  void dispose() {
    super.dispose();
    stopTakingMeasurements(dispose: true);
  }

  Future<void> startTakingMeasurements() async {
    // Make sure we have location permission required for BLE scanning
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/plastic');
                }, // handle your image tap here
                child: Image.network(
                    "https://i.ibb.co/LRGDzQG/Bouteille.png",
                    height: 173.3,
                    width: 131.3,
                  ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/meat');
              }, // handle your image tap here
              child: Image.network(
                "https://i.ibb.co/kBSB9sP/Cotelette.png",
                height: 165.4,
                width: 114.3,
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/vegetable');
              }, // handle your image tap here
              child: Image.network(
                "https://i.ibb.co/c8GvHpN/Haricot.png",
                height: 165.4,
                width: 112.1,

              ),
            ),

          ]
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
        )
      ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    measurement.weight.toStringAsFixed(2) + measurement.unit.toString().split('.')[1],
                  ),
                  Text(
                    measurement.stage.toString().split('.')[1],
                  ),
                  Text(
                    measurement.dateTime.toIso8601String(),
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
