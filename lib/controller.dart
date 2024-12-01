import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:generative_ai/app_print.dart';
import 'package:generative_ai/model.dart';
import 'package:generative_ai/repository.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart' as httpParser;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageController extends GetxController {
  final ImageRepository repo = ImageRepository();
  final List<Offset> points = [];
  final GlobalKey repaintBoundaryKey = GlobalKey();
  final GlobalKey repaintBoundaryImageKey = GlobalKey();
  ImageEditModel? response;
  ImageModel? responseNew;
  final TextEditingController controller = TextEditingController();
  final picker = ImagePicker();

  File? selectedImage;
  File? pngImage;

  File? maskFile;

  getImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      update();
    }
  }

  clearMask() {
    points.clear();
    maskFile = null;
    update();
  }

  Future<void> saveMask() async {
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/mask.png').create();
      file.writeAsBytesSync(buffer);
      maskFile = file;
    }
  }

  Future<void> saveImagePng() async {
    RenderRepaintBoundary boundary = repaintBoundaryImageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.png').create();
      file.writeAsBytesSync(buffer);
      pngImage = file;
    }
  }

  convertToPng() async {
    if (selectedImage == null) return;

    img.Image? image = img.decodeImage(selectedImage!.readAsBytesSync());

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    if (image == null) return;
    img.Image thumbnail = img.copyResize(image, width: 300, height: 300);

    // Save the thumbnail as a PNG.
    final tempDir = await getTemporaryDirectory();
    var random = Random();

    File file = await File('${tempDir.path}/${random.nextInt(100)}image.png').create();
    pngImage = await file.writeAsBytes(img.encodePng(thumbnail));
  }

  saveMaskLocal() {
    if (maskFile != null) saveImage(maskFile?.path);
  }

  saveImageLocal() async {
    // await saveImagePng();
    await convertToPng();
    if (pngImage != null) saveImage(pngImage!.path);
  }

  static Future<void> saveImage(String? filePath, {String? fileName}) async {
    if (filePath == null) return;
    String? message;

    try {
      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: filePath);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Image saved to phone';
      }
    } catch (e) {
      message = e.toString();
      Get.snackbar("Error", e.toString());
    }
  }

  editImage() async {
    try {
      // await saveImagePng();
      await convertToPng();
      final Map<String, dynamic> data = {
        "prompt": controller.text,
        "n": 1,
        // "size": "512x512",
      };
      data['image'] = await dio.MultipartFile.fromFile(
        pngImage!.path,
        filename: "image.png",
        contentType: httpParser.MediaType.parse('image/png'),
      );
      data['mask'] = await dio.MultipartFile.fromFile(
        maskFile!.path,
        filename: "mask.png",
        contentType: httpParser.MediaType.parse('image/png'),
      );
      console(data);
      response = await repo.editImage(data);
      console(response.toString());

      update();
    } catch (e) {
      console(e.toString());
      Get.snackbar("Error", e.toString());
    }
  }

  Future<String?> getBase64String(File? file) async {
    try {
      if (file == null) return null;
      List<int>? byte = await file.readAsBytes();
      return base64Encode(byte);
    } catch (e) {
      console(e.toString());
      Get.snackbar("Error", e.toString());
    }
    return null;
  }

  editImageNew() async {
    try {
      String? image64 = await getBase64String(selectedImage);
      String? mask64 = await getBase64String(maskFile);
      final Map<String, dynamic> data = {
        "prompt": controller.text,
        "image": image64,
        "mask_image": mask64,
        "strength": 0.8,
        "width": 1024,
        "height": 1024,
        "steps": 1,
        "guidance": 7.5,
        "seed": 0,
        "scheduler": "euler",
        "output_format": "jpeg",
        "response_format": "b64"
      };

      console(data);
      responseNew = await repo.editImageNew(data);
      console(response.toString());

      update();
    } catch (e) {
      console(e.toString());
      Get.snackbar("Error", e.toString());
    }
  }
}
