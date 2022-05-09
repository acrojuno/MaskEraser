import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maskeraser/utils/processImage.dart';
import 'package:maskeraser/utils/shareImage.dart';

class ProcessedView extends StatelessWidget {
  ProcessedView({
    Key? key,
    required this.inputImg,
    String? outputPath,
  }) : super(key: key);

  Future<File?> inputImg;
  //Future<File?>? outputImg;
  String? outputPath;

  Dio dio = new Dio();

  /*
    processImage(originalImg) {
    // TODO: implement processImage
    throw UnimplementedError();
  }
   */

  @override
  Widget build(BuildContext context) {
    print('프로세스드뷰 들어옴');
    //File img = inputImg! as File;
    //print(img.path);
    print('완료');

    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          title: Text('Processed View'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                shareImage(outputPath!);
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {},
            ),
          ]),
      body: Container(
        color: Colors.black,
        //alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            /*
            FutureBuilder<File?>(
              future: inputImg,
              builder: (_, snapshot) {
                final file = snapshot.data;
                if (file == null) return Container();
                return Image.file(file);
              },
            ),
            */

            FutureBuilder(
              future: inputImg,
              builder: (context, snapshot) {
                final file = snapshot.data;
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
                  return FutureBuilder(
                    future: processImage(file as File),
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
                          return Container(
                              color: Colors.black,
                              alignment: Alignment.center,
                              child: Image.network(outputPath!));
                        default:
                          return Text('default returned');
                      }
                    },
                  );
                  /*
                  String finalPath = '';
                  processImage(file as File).then((value) => finalPath = value);
                  print('finalPath : ' + finalPath);
                  return Image.network(finalPath);
                  */
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}