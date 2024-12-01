import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generative_ai/controller.dart';
import 'package:get/get.dart';

class MaskPainter extends StatefulWidget {
  final File imagePath;

  const MaskPainter({super.key, required this.imagePath});

  @override
  _MaskPainterState createState() => _MaskPainterState();
}

final ImageController controller = Get.put(ImageController());

class _MaskPainterState extends State<MaskPainter> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
            key: controller.repaintBoundaryImageKey,
            child: SizedBox(
              height: 300,
              width: 300,
              child: Image.file(
                widget.imagePath,
                fit: BoxFit.cover,
              ),
            )), // Load the original image

        RepaintBoundary(
          key: controller.repaintBoundaryKey,
          child: CustomPaint(
            size: const Size(300, 300),
            painter: MaskCanvas(points: controller.points),
            // child: Container(),
          ),
        ),
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              controller.points.add(details.localPosition); // Add points to draw
            });
          },
          onPanEnd: (_) => controller.points.add(Offset.zero), // Signal end of stroke
        ),
      ],
    );
  }
}

class MaskCanvas extends CustomPainter {
  final List<Offset> points;

  MaskCanvas({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.largest, Paint());
    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final eraserPaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    // final paint = Paint()
    //   ..color = Colors.red
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 15;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], eraserPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
