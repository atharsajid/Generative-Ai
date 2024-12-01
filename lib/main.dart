import 'package:flutter/material.dart';
import 'package:generative_ai/controller.dart';
import 'package:generative_ai/custom_cached_network_image.dart';
import 'package:generative_ai/mask_painter.dart';
import 'package:get/get.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final ImageController controller = Get.put(ImageController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        body: GetBuilder(
            init: controller,
            builder: (_) {
              print(controller.response?.data.firstOrNull?.url);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.selectedImage != null)
                    SizedBox(
                      height: 300,
                      child: MaskPainter(imagePath: controller.selectedImage!),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.getImage();
                        },
                        child: const Text("Pick Image"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.saveMask();
                        },
                        child: const Text("Save Mask"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.clearMask();
                        },
                        child: const Text("Clear Mask"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.saveImageLocal();
                        },
                        child: const Text("Save Image Local"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.saveMaskLocal();
                        },
                        child: const Text("Save Mask Local"),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: controller.controller,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.editImage();
                    },
                    child: const Text("Edit Image"),
                  ),
                  if (controller.response?.data.firstOrNull?.url != null)
                    SizedBox(
                      height: 200,
                      child: CustomCachedNetworkImage(
                        imageUrl: controller.response!.data.firstOrNull!.url!,
                      ),
                    ),
                ],
              );
            }),
      ),
    );
  }
}
