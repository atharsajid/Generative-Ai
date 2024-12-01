import 'package:generative_ai/data/app_url.dart';
import 'package:generative_ai/data/network/network_services.dart';
import 'package:generative_ai/model.dart';

class ImageRepository {
  Future<ImageEditModel?> editImage(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices.ins.postFile(AppUrl.edit, data);
      return ImageEditModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ImageModel?> editImageNew(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices.ins.post(AppUrl.edit, data);
      return ImageModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
