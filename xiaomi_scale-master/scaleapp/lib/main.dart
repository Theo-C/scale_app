import 'package:flutter/material.dart';
import 'package:xiaomi_scale_example/loading.dart';
import 'package:xiaomi_scale_example/measure.dart';
import 'package:xiaomi_scale_example/measurement_pane.dart';
import 'package:xiaomi_scale_example/paper.dart';
import 'package:xiaomi_scale_example/plastic.dart';
import 'package:xiaomi_scale_example/option.dart';
import 'package:xiaomi_scale_example/raw_data_pane.dart';
import 'package:xiaomi_scale_example/organic.dart';
import 'package:xiaomi_scale_example/glass.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(ScaleApp());

}


class ScaleApp extends StatefulWidget {
  @override
  _ScaleAppState createState() => _ScaleAppState();
}

class _ScaleAppState extends State<ScaleApp> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        routes: {
          '/organic': (context) => Organic(),
          '/plastic': (context) => Plastic(),
          '/glass': (context) => Glass(),
          '/measure': (context) => Measure(),
          '/home': (context) => ScaleApp(),
          '/paper': (context) => Paper()
        },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('C-Antigaspi'),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Measure(),
            Option()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _bottomTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black45,
          backgroundColor: Colors.grey[200],
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              title: Text('Mesurer'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Options'),
            ),
          ],
        ),

      ),

    );

  }


  void _bottomTapped(int index) => setState(() => _currentIndex = index);


}
