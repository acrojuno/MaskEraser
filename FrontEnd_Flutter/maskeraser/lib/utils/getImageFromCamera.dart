import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> getImagefromcamera() async {
  var image = await ImagePicker().pickImage(source: ImageSource.camera);

  //await Future.delayed(Duration(milliseconds: 2000));
  //File imgFile = File(image!.path);

  Directory appDirectory = await getTemporaryDirectory();
  File newImage = File(appDirectory.path + 'capturedImg.jpg');
  newImage.writeAsBytes(File(image!.path).readAsBytesSync());

  return newImage;
}
