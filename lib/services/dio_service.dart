import 'package:dio/dio.dart';
import 'package:fd_downloader/services/secure_storage_service.dart';

class DioService {
  static Dio? _dio;

  static Future<Dio> getInstance() async {
    if (_dio != null) return _dio!;

    final baseUrl = await SecureStorageService.readBaseUrl() ?? '';

    _dio = Dio(BaseOptions(baseUrl: baseUrl));

    return _dio!;
  }
}
