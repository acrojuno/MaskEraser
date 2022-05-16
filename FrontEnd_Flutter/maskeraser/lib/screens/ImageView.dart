import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maskeraser/screens/ProcessedView.dart';

class ImageView extends StatelessWidget {
  const ImageView({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  final Future<File?> imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text('Image View'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            }),
      ),
      body: Container(
        color: Colors.black,
        //alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //ImageView에 해당하는 이미지 띄우기
            FutureBuilder<File?>(
              future: imageFile,
              builder: (_, snapshot) {
                final file = snapshot.data;
                //originalImg = file as Future<File?>;
                if (file == null) return Container();
                return Image.file(file);
              },
            ),
            Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                //마스크 제거 버튼
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProcessedView(inputImg: imageFile),
                    ),
                    (route) => true,
                  ),
                  child: Icon(Icons.masks, size: 40),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(CircleBorder()),
                    minimumSize: MaterialStateProperty.all(Size(60, 60)),
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.pressed))
                        return Colors.green;
                    }),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
