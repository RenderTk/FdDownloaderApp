import 'package:fd_downloader/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiBaseUrlNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return await SecureStorageService.readBaseUrl();
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await SecureStorageService.saveBaseUrl(baseUrl);
      return await SecureStorageService.readBaseUrl();
    });
  }
}

final apiBaseUrlProvider = AsyncNotifierProvider<ApiBaseUrlNotifier, String?>(
  ApiBaseUrlNotifier.new,
);
