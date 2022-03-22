import 'dart:io';
//import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'dart:async';

//http 이용해서 이미지 서버로 업로드 하는 함수
/**
 * accepts three parameters, the endpoint, formdata (except fiels),files (key,File)
 * returns Response from server
 */
Future<Response> sendForm(
    String url, Map<String, dynamic> data, Map<String, XFile?> files) async {
  Map<String, MultipartFile> fileMap = {};
  for (MapEntry fileEntry in files.entries) {
    File file = fileEntry.value;
    String fileName = basename(file.path);
    fileMap[fileEntry.key] =
        MultipartFile(file.openRead(), await file.length(), filename: fileName);
  }
  data.addAll(fileMap);
  var formData = FormData.fromMap(data);
  Dio dio = new Dio();
  return await dio.post(url,
      data: formData, options: Options(contentType: 'multipart/form-data'));
}

/**
 * accepts two parameters,the endpoint and the file
 * returns Response from server
 */
Future<Response> sendFile(String url, XFile file) async {
  Dio dio = new Dio();
  var len = await file.length();
  var response = await dio.post(url,
      data: file.openRead(),
      options: Options(headers: {
        Headers.contentLengthHeader: len,
      } // set content-length
      ));
  return response;
}


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ScreenUtil : 반응형(크기에 따라 자동으로 크기 조절되는) 위젯을 만들기 위한 패키지
    return ScreenUtilInit(
      //디바이스 사이즈 설정(단위: dp)
      designSize: Size(320, 533),
      minTextAdapt: true,
      //splitScreenMode: true,
      builder: () => MaterialApp(
        builder: (context, widget) {
          ScreenUtil.setContext(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  Dio dio = new Dio();




  /* 카메라로 직접 찍은 사진을 가져와 컨테이너(박스)에 넣는 함수
  Future getImagefromcamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
    });
  }
  */

  //갤러리에서 사진을 가져와 컨테이너(박스)에 넣는 함수
  Future getImagefromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    //upload image
    //scenario  one - upload image as poart of formdata
    var res1 = await sendForm('http://192.168.43.236:4082/create-profile',
        {'name': 'iciruit', 'des': 'description'}, {'profile': image});
    print("res-1 $res1");

    setState(() {
      _image = File(image!.path);
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('MaskEraser v0.01'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: ScreenUtil().setWidth(100),
                //setHeight가 아니라 높이도 setWidth로 해야 정사각형 유지 가능
                height: ScreenUtil().setWidth(100),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all()
                ),
                child: _image == null
                  ? Center(child: Text("선택된 이미지가 없습니다"))
                    :Image.file(_image!),
              ),
              Icon(Icons.arrow_forward, size: 30),
              Container(
                width: ScreenUtil().setWidth(100),
                height: ScreenUtil().setWidth(100),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all()
                ),
                child: Center(child: Text('변환된 이미지가 없습니다.')),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: Text('마스크를 제거할 사진을 첨부해주세요'),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: ElevatedButton(onPressed: getImagefromGallery, child: Text('사진 첨부')),
          ),

        ],
      ),
    );
  }
}