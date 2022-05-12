import 'package:flutter/cupertino.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  @override
  Widget build(BuildContext context) {
    return Container(
            child: Text('카메라 화면입니다.'),
          );
  }
}