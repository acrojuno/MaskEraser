import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maskeraser/utils/GalleryThumbnail.dart';
import 'package:maskeraser/utils/data.dart';
import 'package:photo_manager/photo_manager.dart';

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

  //final controller = DragSelectGridViewController();

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