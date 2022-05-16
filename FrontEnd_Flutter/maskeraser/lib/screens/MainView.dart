import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:maskeraser/screens/GuideView.dart';

import 'package:maskeraser/screens/Home.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Dio dio = new Dio();

  @override
  void initState() {
    super.initState();
    //controller.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    //controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Mask Eraser'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: () {
              Phoenix.rebirth(context);
            },
          ),
        ],
      ),
      body: Home(),
    );
  }

  //void scheduleRebuild() => setState(() {});
}
