import 'package:fd_downloader/services/dio_service.dart';
import 'package:fd_downloader/services/storage_service.dart';
import 'package:uuid/uuid.dart';

final String instagramUrl = "http://192.168.4.156:8002/instagram";

final String tiktokUrl = "http://192.168.4.156:8002/tiktok";

final String youtubeUrl = "http://192.168.4.156:8002/youtube";

class DownloaderService {
  Future<void> downloadReel(String url) async {
    try {
      final uuid = Uuid();
      final dio = DioService.dio;
      final storageService = StorageService();

      // Generate unique filename
      final fileName = "${uuid.v4()}.mp4";
      final filePath = await storageService.getVideoFilePath(
        fileName,
        customFolder: "FdDownloader",
      );

      // Check if filePath is null
      if (filePath == null) {
        throw Exception("Failed to get video file path");
      }

      final response = await dio.download(
        instagramUrl, // This should probably be a configurable endpoint
        filePath,
        queryParameters: {"url": url},
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print("Download progress: $progress%");
          }
        },
      );

      // Check response status
      if (response.statusCode != 200) {
        // Clean up failed download
        await storageService.deleteFile(filePath);
        throw Exception("Download failed.");
      }
    } catch (e) {
      throw Exception("Error downloading the Instagram reel: $e");
    }
  }
}
