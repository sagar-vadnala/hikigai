import 'package:dio/dio.dart';

abstract class ApiUtils {
  static Map<String, dynamic> handleDioException(DioException exception) {
    Map<String, dynamic> tempMap = {
      'code': 'UNKNOWN',
      'error': 'Something went wrong',
    };

    if (exception.response != null) {
      if (exception.response!.data != null) {
        if (exception.response!.data is Map) {
          tempMap = Map.from(exception.response!.data).cast<String, dynamic>();
        } else {
          tempMap['error'] = exception.response!.data;
        }
      } else {
        tempMap['error'] = exception.message;
      }
    }

    return tempMap;
  }

  static String renderException(dynamic e) {
    if (e == null || e is! Exception) {
      return '';
    }
    return e.toString().replaceAll(RegExp(r'(Exception):?'), '').trim();
  }
}
