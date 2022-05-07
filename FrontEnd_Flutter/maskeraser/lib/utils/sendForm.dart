import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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