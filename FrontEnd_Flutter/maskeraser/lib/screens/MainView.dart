import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:maskeraser/utils/GalleryThumbnail.dart';
import 'package:maskeraser/utils/data.dart';
import 'package:photo_manager/photo_manager.dart';
=======
import 'package:maskeraser/screens/CamTest.dart';
import 'package:maskeraser/screens/ImageView.dart';
import 'package:maskeraser/utils/getImageFromCamera.dart';

import 'package:maskeraser/screens/Home.dart';
>>>>>>> Stashed changes

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

List<AssetEntity> assets = [];

late PageController _pageController;
int _page = 1;

class _MainViewState extends State<MainView> {
  File? _image;
  String? _output_image;
  bool _isloading = false;
  Dio dio = new Dio();

<<<<<<< Updated upstream
  //final controller = DragSelectGridViewController();
=======
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

  // 페이지 번호 -> CamTest.dart : 0번, Home.dart : 1번
  List<Widget> _widgetOptions = <Widget>[
    CamTest(), //전혀 쓰이지 않음. 사실상 필요 없음. 하단 navigationTapped 함수 참조
    Home(),
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
>>>>>>> Stashed changes

  _fetchAssets() async {
    final albums = await PhotoManager.getAssetPathList(
        onlyAll: true, type: RequestType.image);
    final recentAlbum = albums.first;

    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );

    setState(() => assets = recentAssets);
  }

  @override
  void initState() {
    _fetchAssets();
    super.initState();
    //controller.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    //controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  /* 카메라로 직접 찍은 사진을 가져와 컨테이너(박스)에 넣는 함수
  Future getImagefromcamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
    });
  }
  */

  // 서버로부터 json형태의 데이터를 가져오는 함수
  Future getImagefromServer() async {
    var res2 = await dio.get("http://10.0.2.2:8000/getoutput/");
    Map<String, dynamic> jsonData = res2.data;

    print(jsonData);

    setState(() {
      _output_image = jsonData['output'];
      _isloading = false;
    });
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
      body: ListView(
        //padding: EdgeInsets.only(left:20),
        children: <Widget>[
          Text(
            '최근 이미지',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
              color: Colors.black,
            ),
          ),

          /*
          Container(
            child: DragSelectGridView(
              gridController: controller,
              padding: const EdgeInsets.all(8),
              itemCount: 90,
              itemBuilder: (context, index, selected) {
                return SelectableItem(
                  index: index,
                  color: Colors.blue,
                  selected: selected,
                );
              },
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            ),
          ),
          */

          Container(
            height: 150,
            child: ListView.builder(
              //physics: NeverScrollableScrollPhysics(),
              physics: ScrollPhysics(),
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                Map story = data[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(story['story']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Text(
            '갤러리',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
              color: Colors.black,
            ),
          ),
          Container(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              //physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: assets.length,
              itemBuilder: (_, index) {
                return GalleryThumbnail(asset: assets[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //showSelectedLabels: false,
        //showUnselectedLabels: false,
        onTap: navigationTapped,
        currentIndex: _page,

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void scheduleRebuild() => setState(() {});
}

void navigationTapped(int page) {
  _pageController.jumpToPage(page);
}