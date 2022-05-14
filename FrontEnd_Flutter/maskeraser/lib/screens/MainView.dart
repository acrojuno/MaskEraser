import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maskeraser/utils/GalleryThumbnail.dart';
import 'package:maskeraser/utils/data.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:maskeraser/screens/Home.dart';
import 'package:maskeraser/screens/Camera.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  File? _image;
  String? _output_image;
  bool _isloading = false;
  Dio dio = new Dio();

  // 처음 실행 페이지: Home(1)
  int _pageIndex = 1;

  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.photo_camera),
      label: '카메라',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '홈',
    ),
  ];

  // 페이지 번호 -> Camera.dart : 0번, Home.dart : 1번
  List<Widget> _widgetOptions = <Widget>[
    Camera(),
    Home(),
  ];

  // 버튼을 누르면, 해당하는 페이지 주소 int값을 반환
  void navigationTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

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
          title: Text('MaskEraser TEST v0.02'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.masks),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ]),
      body: _widgetOptions[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //showSelectedLabels: false,
        //showUnselectedLabels: false,
        onTap: navigationTapped,
        currentIndex: _pageIndex,
        items: bottomItems,
      ),
    );
  }

  void scheduleRebuild() => setState(() {});
}
