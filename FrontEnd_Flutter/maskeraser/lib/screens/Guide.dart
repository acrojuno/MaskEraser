import 'package:flutter/cupertino.dart';

class Guide extends StatefulWidget {
  @override
  _GuideState createState() => _GuideState();
}

class _GuideState extends State<Guide> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          Container(
              child: Text('가이드 화면입니다.'),
          )
        ]
    );
  }
}