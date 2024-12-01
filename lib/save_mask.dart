import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:generative_ai/mask_painter.dart';

class SaveMask extends StatelessWidget {
  final String imagePath;
  SaveMask({
    required this.imagePath,
  });
  final GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: CustomPaint(
        // painter: CustomPainter(
        //   imagePath: imagePath,
        // ),
        child: Container(),
      ),
    );
  }

  Future<void> saveMask() async {
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      final buffer = byteData.buffer.asUint8List();
      // Save buffer to file or send as a base64 string
    }
  }
}
