import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:maskeraser/screens/ImageView.dart';

class GalleryThumbnail extends StatelessWidget {
  const GalleryThumbnail({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            if (asset.type == AssetType.image) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageView(imageFile: asset.file),
                ),
              );
            }

            // TODO: navigate to the video screen
          },
          child: Positioned.fill(
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
