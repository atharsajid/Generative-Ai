import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:generative_ai/app_print.dart';
import 'package:generative_ai/data/app_url.dart';
import 'package:generative_ai/data/network/app_exception.dart';
import 'package:generative_ai/data/network/base_network_service.dart';

class NetworkApiServices extends BaseApiServices {
  final Dio dio = Dio(
    BaseOptions(baseUrl: AppUrl.baseUrl, connectTimeout: const Duration(seconds: 600), headers: {
      'Content-Type': 'application/json',
    }),
  );

  static final NetworkApiServices ins = NetworkApiServices._();

  NetworkApiServices._() {
    updateDio();
  }
  static const connectionTimeOut = Duration(seconds: 500);
  @override
  Future<Map<String, dynamic>> post(String endPoint, Map<String, dynamic> data, {Map<String, dynamic> queryParameters = const {}}) async {
    Response? response;
    try {
      response = await dio.post(
        endPoint,
        data: jsonEncode(data),
        options: getAccessToken(),
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleException(e);
    } on SocketException catch (_) {
      throw InternetException('No Internet Connection.');
    }

    return response?.data;
  }

  @override
  Future<Map<String, dynamic>> patch(String endPoint, Map<String, dynamic> data,
      {Map<String, dynamic> queryParameters = const {}, bool isFormData = false}) async {
    Response? response;
    try {
      response = await dio.patch(
        endPoint,
        data: isFormData ? FormData.fromMap(data) : jsonEncode(data),
        options: isFormData
            ? Options(
                contentType: 'multipart/form-data',
                sendTimeout: connectionTimeOut,
                receiveTimeout: connectionTimeOut,
              )
            : getAccessToken(),
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleException(e);
    } on SocketException catch (_) {
      throw InternetException('No Internet Connection.');
    }

    return response?.data;
  }

  @override
  Future<Map<String, dynamic>?> update(String endPoint, Map<String, dynamic> data, {Map<String, dynamic> queryParameters = const {}}) async {
    Response? response;
    try {
      response = await dio.put(endPoint, data: jsonEncode(data), options: getAccessToken(), queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleException(e);
    } on SocketException catch (_) {
      throw InternetException('No Internet Conn0ection.');
    }
    return response?.data;
  }

  @override
  Future<Map<String, dynamic>> postFile(String endPoint, Map<String, dynamic> data, {Map<String, dynamic> queryParameters = const {}}) async {
    Response? response;
    try {
      console(data, name: "Payload");
      console(AppUrl.baseUrl + endPoint, name: "Url");
      console(dio.options.headers, name: "Header");
      response = await dio.post(
        endPoint,
        data: FormData.fromMap(data),
        options: Options(
          method: 'POST',
          contentType: 'multipart/form-data',
          sendTimeout: connectionTimeOut,
          receiveTimeout: connectionTimeOut,
        ),
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleException(e);
    } on SocketException catch (_) {
      throw InternetException('No Internet Connection.');
    }
    return response?.data;
  }

  @override
  Future<Map<String, dynamic>?> delete(String endPoint, {Map<String, dynamic> queryParameters = const {}, Map<String, dynamic>? data}) async {
    Response? response;
    try {
      response = await dio.delete(
        endPoint,
        options: getAccessToken(),
        queryParameters: queryParameters,
        data: data != null ? jsonEncode(data) : null,
      );
    } on DioException catch (e) {
      _handleException(e);
    } on SocketException catch (_) {
      throw InternetException('No Internet Connection.');
    }
    return response?.data;
  }

  @override
  Future<Map<String, dynamic>?> get(String endPoint, {Map<String, dynamic> queryParameters = const {}}) async {
    Response? response;
    try {
      console(dio.options.headers, name: "Header");
      console(dio.options.baseUrl + endPoint, name: "Url");

      response = await dio.get(
        endPoint,
        options: getAccessToken(),
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleException(e);
    } on SocketException catch (_) {
      throw InternetException('No Internet Connection.');
    }
    return response?.data;
  }

  Options getAccessToken() {
    return Options(responseType: ResponseType.json);
  }

  void updateDio() async {
    updateAuthDio(AppUrl.token);
  }

  void updateAuthDio(String authToken) {
    dio.options.headers = <String, dynamic>{'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json'};
    console("${dio.options.headers}", name: 'Update Auth dio');
  }

  void _handleException(DioException e) {
    console(e.response, name: 'DioException', color: LogColors.red);
    console(e.response?.realUri.toString(), name: 'URL', color: LogColors.red);
    console(e.response?.requestOptions.headers.toString(), name: 'Headers', color: LogColors.red);

    if (e.type == DioExceptionType.badResponse) {
      String msg = e.response?.data["message"] as String? ?? e.message.toString();
      // e.response?.data['raw']['message'] ??
      //  msg =
      // e.response?.data["message"] as String? ?? e.message.toString();

      switch (e.response?.statusCode) {
        case 400:
          throw ApiException(msg);
        case 401:
          throw ApiException(msg);
        case 404:
          throw ApiException(msg);
        case 500:
          throw BadRequestException(msg);
        default:
          throw FetchDataException("Oops! Something went wrong.");
      }
    } else if (e.type == DioExceptionType.connectionError) {
      throw InternetException('');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw RequestTimeOut('');
    }
  }
}
