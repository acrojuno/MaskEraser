import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Dio dio = new Dio();

Future<void> shareImage(String networkPath) async {
  final temp = await getTemporaryDirectory();
  final filePath = '${temp.path}/shareImage.jpg';
  await dio.download(networkPath, filePath);
  /*
  print('downloadPath에 이미지 파일이 존재하냐? : '
      '${await File(networkPath).exists()}');
  */
  await Share.shareFiles([filePath], text: 'Image Shared');
}
