import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maskeraser/screens/CamTest.dart';
import 'package:maskeraser/screens/ImageView.dart';
import 'package:maskeraser/utils/getImageFromCamera.dart';

import 'package:maskeraser/screens/Home.dart';
import 'package:maskeraser/screens/Guide.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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
    BottomNavigationBarItem(
      icon: Icon(Icons.lightbulb),
      label: '가이드',
    ),
  ];

  // 페이지 번호 -> CamTest.dart : 0번, Home.dart : 1번, Guide.dart : 2번
  List<Widget> _widgetOptions = <Widget>[
    CamTest(), //전혀 쓰이지 않음. 사실상 필요 없음. 하단 navigationTapped 함수 참조
    Home(),
    Guide(),
  ];

  // 버튼을 누르면, 해당하는 페이지 주소 int값을 반환
  void navigationTapped(int index) {
    //0번값(카메라 버튼)이 들어왔을 때(카메라 버튼 기능만 따로 구현함)
    if (index == 0) {
      Future<File?> img = getImagefromcamera();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageView(
            imageFile: img,
          ),
        ),
      );
      index = 1;
    }

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
      ),
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
