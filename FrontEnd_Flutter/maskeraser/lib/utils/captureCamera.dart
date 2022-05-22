import 'dart:io';

import 'package:flutter/material.dart';

import 'package:maskeraser/screens/ImageView.dart';
import 'package:maskeraser/utils/getImageFromCamera.dart';

Future captureCamera(BuildContext context) async {
  Future<File?> img = getImagefromcamera();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ImageView(
        imageFile: img,
      ),
    ),
  );
}
