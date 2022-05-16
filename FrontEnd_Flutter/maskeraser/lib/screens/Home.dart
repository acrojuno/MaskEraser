import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maskeraser/screens/ProcessedView.dart';
import 'package:maskeraser/utils/GalleryThumbnail.dart';
import 'package:maskeraser/utils/captureCamera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

List<AssetEntity> assets = [];
List<FileSystemEntity> entities = [];

RefreshController _refreshController = RefreshController(initialRefresh: false);

class _HomeState extends State<Home> {
  Dio dio = new Dio();

  //새로고침(위에서 아래로 당기기) 시 수행할 것들
  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _fetch();
    _refreshController.refreshCompleted();
  }

  //처음 실행 시 불러올 것들
  _fetch() async {
    //기기 내부에 있는 모든 사진 파일들 불러오기
    final albums = await PhotoManager.getAssetPathList(
        onlyAll: true, type: RequestType.image);
    final recentAlbum = albums.first;

    //최대 1000000개까지 로드
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );

    //앱 내부 디렉토리 get
    final dir = await getApplicationDocumentsDirectory();
    //메인화면 상단 가로 스크롤 위젯에 들어갈 이미지들이 저장된 폴더 경로 지정(String 값)
    final path = dir.path + '/ListViewImages';

    //path 경로에 폴더가 없으면 새로 생성
    !await Directory(path).exists()
        ? Directory(path).create()
        : print('Passed Directory Check');

    //가로 스크롤 위젯에 들어갈 이미지들 리스트에 저장(생성 시점 기준 정렬)
    List<FileSystemEntity> recentEntities = await Directory(path)
        .list()
        .toList()
      ..sort((l, r) => l.statSync().modified.compareTo(r.statSync().modified));
    //테스트 해 보니 순서가 거꾸로 나와서 리스트를 한번 뒤집어 줌
    recentEntities = List.from(recentEntities.reversed);

    setState(() => entities = recentEntities);
    setState(() => assets = recentAssets);
  }

  @override
  void initState() {
    _fetch();
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () {
          captureCamera(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //SmartRefresher : 위에서 아래로 땡기면 새로고침 지원하는 위젯
      body: SmartRefresher(
        enablePullDown: true, //위에서 아래로 땡겨서 새로고침
        enablePullUp: false, //아래로 스크롤하면 다음 내용 불러오기
        controller: _refreshController,
        onRefresh: _onRefresh, //새로고침 때 뭘 새로고침 할건지
        child: ListView(
          //padding: EdgeInsets.only(left:20),
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: Text(
                '최근 이미지',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 0.27,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 150,

              //최근 이미지 위젯(가로 스크롤)
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                //physics: NeverScrollableScrollPhysics(),
                physics: ScrollPhysics(),
                itemCount: entities.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  FileSystemEntity entity = entities[index];
                  Future<File?>? selectedImg;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    child: InkWell(
                      onTap: () async {
                        selectedImg = File(entity.path).create();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProcessedView(
                              inputImg: selectedImg!,
                              isRecent: true,
                            ),
                          ),
                        ).then((value) => {_fetch()});
                      },
                      child: Container(
                        height: 150,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 1.5,
                              blurRadius: 5,
                              offset:
                                  Offset(3, 3), // changes position of shadow
                            ),
                          ],
                          image: DecorationImage(
                            image: Image.file(File(entity.path)).image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Text(
                '갤러리',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 0.27,
                  color: Colors.black,
                ),
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
                  //갤러리 위젯(세로 스크롤)
                  return GalleryThumbnail(asset: assets[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //void scheduleRebuild() => setState(() {});
}
