import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:maskeraser/utils/processImage.dart';
import 'package:maskeraser/utils/shareImageUrl.dart';

class ProcessedView extends StatelessWidget {
  ProcessedView({
    Key? key,
    required this.inputImg,
    String? outputPath,
    bool? this.isRecent = false,
  }) : super(key: key);

  Future<File?> inputImg;

  String? outputPath;

  bool? isRecent;

  Dio dio = new Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          title: Text('Processed View'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                if (isRecent == true) {
                  File? file = await inputImg;
                  Share.shareFiles([file!.path]);
                } else {
                  shareImage(outputPath!);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.save), //저장 버튼
              onPressed: () async {
                //저장소 권한 확인
                var status = await Permission.storage.status;
                if (!status.isGranted) {
                  await Permission.storage.request();
                }

                //기기 내 다운로드 폴더 지정
                const deviceDir = 'storage/self/primary/Download/';
                var name;

                //앱 상단 최근 이미지 위젯으로 접근할 때
                if (isRecent == true) {
                  //앱 내부 'ListViewImages' 폴더에 있는 해당 파일을 복사
                  File? file = await inputImg;
                  name = await basename(file!.path);
                  file.copy('$deviceDir/$name');
                } else { //사진 변환 직후일 때
                  name = await basename(outputPath!);
                  await dio.download(outputPath!, join(deviceDir, 'downloaded_${name}'));
                }

                //다운로드 완료 토스트 메시지 출력
                Fluttertoast.showToast(
                  msg: '다운로드 완료',
                  fontSize: 20,
                );
              },
            ),
          ]),
      body: Container(
        color: Colors.black,
        //alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            FutureBuilder(
              future: inputImg,
              builder: (context, snapshot) {
                final inputFile = snapshot.data;
                if (snapshot.hasData == false) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  switch (isRecent) {
                    case true:
                      return Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: Image.file(inputFile as File));
                    default:
                      return FutureBuilder(
                        future: processImage(inputFile as File),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.active:
                              return Text('The connection is active.');
                            case ConnectionState.waiting:
                              Fluttertoast.showToast(
                                msg: '이미지 변환 중\n잠시만 기다려주세요',
                                fontSize: 20,
                              );
                              return Container(
                                color: Colors.black,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            case ConnectionState.done:
                              Fluttertoast.showToast(
                                msg: '이미지 변환 완료',
                                fontSize: 20,
                              );
                              outputPath = snapshot.data! as String;
                              saveInApp(outputPath!);
                              //Navigator.pop(context, true);
                              return Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: Image.network(outputPath!));
                            default:
                              return Text('default returned');
                          }
                        },
                      );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveInApp(String outputPath) async {
  final File file = new File(outputPath);
  final fileName = basename(file.path);

  final appDir = await getApplicationDocumentsDirectory();
  var filePath = '${appDir.path}/ListViewImages/${fileName}';
  await dio.download(outputPath, filePath);
  print('appPath : ${filePath}');
}
