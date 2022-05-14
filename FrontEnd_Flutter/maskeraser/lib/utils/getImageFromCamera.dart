import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> getImagefromcamera() async {
  var image = await ImagePicker().pickImage(source: ImageSource.camera);

  //File imgFile = File(image!.path);

  Directory appDirectory = await getApplicationDocumentsDirectory();
  File newImage = File(appDirectory.path + 'capturedImg.jpg');
  newImage.writeAsBytes(File(image!.path).readAsBytesSync());

  return newImage;
}