import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'sendForm.dart';

Future<String> processImage(File? image) async {
  XFile img = XFile(image!.path);

  //upload image
  //scenario  one - upload image as poart of formdata
  var res1 = await sendForm('http://10.0.2.2:8000/Post/',
=======
  var res1 = await sendForm('http://dltjdeh.iptime.org:100/Post/',
>>>>>>> Stashed changes
      {'userId': 'tetetest', 'quantity': 1}, {'input': img});
  print("res-1 $res1");

  //마스크 제거 처리된 이미지 서버로부터 가져오기
  Dio dio = new Dio();
  var res2 = await dio.get("http://10.0.2.2:8000/getoutput/");
=======
  var res2 = await dio.get("http://dltjdeh.iptime.org:100/getoutput/");
>>>>>>> Stashed changes
  Map<String, dynamic> jsonData = res2.data;

  print('서버에서 받은 json 데이터 : ');
  print(jsonData);

  String outputPath = jsonData['output'];

  return outputPath;
}