import 'dart:io';
//import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
//import 'package:cached_network_image/cached_network_image.dart';
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
    XFile file = fileEntry.value;
    String fileName = path.basename(file.path);
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

/*
Future<Response> sendFile(String url, File file) async {
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
*/
/*
Future<Response> get(String url) async {
  Dio dio = new Dio();
  try {
    Response response = await dio.get(url);
  }
}
*/

class User {
  String id;
  String output; //image의 경로를 저장
  int quantity;

  User({
    required this.id,
    required this.output,
    required this.quantity,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      output: json['output'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'output': output, 'quantity': quantity};
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
  String? _output_image;
  bool _isloading = false;
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

    if (image != null) {
      image.path;
    }

    /*
    String dir = path.dirname(image!.path);
    String now_date = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    String newName = path.join(dir, now_date);
    File(image.path).renameSync(newName);
     */

    print('upload started');

    //upload image
    //scenario  one - upload image as poart of formdata
    var res1 = await sendForm('http://10.0.2.2:8000/Post/',
        {'userId': 'testt', 'quantity': 1}, {'input': image});
    print("res-1 $res1");

    setState(() {
      _image = File(image!.path);
      _isloading = true;
    });

    getImagefromServer();
  }

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
        title: Text('MaskEraser v0.01'),
      ),
      body: Stack(children: [
        Center(
          child: _isloading == true
              ? CircularProgressIndicator()
              : SizedBox(),
        ),
        Column(
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
                  decoration: BoxDecoration(border: Border.all()),
                  child: _image == null
                      ? Center(child: Text("선택된 이미지가 없습니다"))
                      : Image.file(_image!),
                ),
                Icon(Icons.arrow_forward, size: 30),
                Container(
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setWidth(100),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border.all()),
                  child: _output_image == null
                      ? Center(child: Text("변환된 이미지가 없습니다"))
                      : Image.network(_output_image!)
                 /*
                  SizedBox(
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: _output_image!,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  width: 40.0,
                                  height: 40.0,
                                  child: new CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                            ),
                          ),
                          height: 100,
                          width: 100,
                        ),
                  */
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: _isloading == false
                  ? Text('마스크를 제거할 사진을 첨부해주세요')
              : Text('변환 중입니다. 잠시만 기다려주세요.'),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: getImagefromGallery, child: Text('사진 첨부')),
            ),
            /*
            Container(
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: getImagefromServer, child: Text('사진 변환')),
            ),
            */
          ],
        ),
      ]),
    );
  }
}
