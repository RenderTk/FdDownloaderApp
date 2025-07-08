import 'package:fd_downloader/providers/download_progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fd_downloader/services/dio_service.dart';
import 'package:fd_downloader/services/storage_service.dart';
import 'package:uuid/uuid.dart';

enum FileType { video, audio }

enum Plataforma { youtube, instagram, tiktok }

final String instagramUrl = "http://192.168.4.156:8002/instagram";

final String tiktokUrl = "http://192.168.4.156:8002/tiktok";

final String youtubeUrl = "http://192.168.4.156:8002/youtube";

class DownloaderService {
  /// Helper function to validate Instagram Reel URLs
  bool isValidInstagramReelUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final instagramReelPatterns = [
      RegExp(
        r'^https?:\/\/(www\.)?instagram\.com\/reel\/[A-Za-z0-9_-]+\/?(\?.*)?$',
      ),
      RegExp(
        r'^https?:\/\/(www\.)?instagram\.com\/p\/[A-Za-z0-9_-]+\/?(\?.*)?$',
      ),
    ];

    return instagramReelPatterns.any((pattern) => pattern.hasMatch(url));
  }

  /// Helper function to validate TikTok video URLs
  bool isValidTikTokUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final tiktokPatterns = [
      RegExp(
        r'^https?:\/\/(www\.)?tiktok\.com\/@[A-Za-z0-9._-]+\/video\/\d+(\?.*)?$',
      ),
      RegExp(r'^https?:\/\/(vm\.)?tiktok\.com\/[A-Za-z0-9]+\/?(\?.*)?$'),
      RegExp(r'^https?:\/\/(www\.)?tiktok\.com\/t\/[A-Za-z0-9]+\/?(\?.*)?$'),
    ];

    return tiktokPatterns.any((pattern) => pattern.hasMatch(url));
  }

  /// Helper function to validate YouTube video URLs
  bool isValidYouTubeUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final youtubePatterns = [
      RegExp(
        r'^https?:\/\/(www\.)?youtube\.com\/watch\?v=[A-Za-z0-9_-]{11}(&.*)?$',
      ),
      RegExp(
        r'^https?:\/\/(www\.)?youtube\.com\/embed\/[A-Za-z0-9_-]{11}(\?.*)?$',
      ),
      RegExp(r'^https?:\/\/(www\.)?youtube\.com\/v\/[A-Za-z0-9_-]{11}(\?.*)?$'),
      RegExp(r'^https?:\/\/youtu\.be\/[A-Za-z0-9_-]{11}(\?.*)?$'),
      RegExp(
        r'^https?:\/\/(www\.)?youtube\.com\/shorts\/[A-Za-z0-9_-]{11}(\?.*)?$',
      ),
    ];

    return youtubePatterns.any((pattern) => pattern.hasMatch(url));
  }

  Future<String> getFileSavePath(FileType type) async {
    final uuid = Uuid();
    final storageService = StorageService();

    final extension = type == FileType.video ? ".mp4" : ".mp3";
    // Generate unique filename
    final fileName = "${uuid.v4()}$extension";
    final filePath = await storageService.getVideoFilePath(fileName);

    // Check if filePath is null
    if (filePath == null) {
      throw Exception("Failed to get video file path");
    }

    return filePath;
  }

  Future<void> downloadReel(String url, WidgetRef ref) async {
    try {
      if (!isValidInstagramReelUrl(url)) {
        throw Exception("Invalid Instagram reel URL.");
      }

      final dio = DioService.dio;
      final filePath = await getFileSavePath(FileType.video);

      final response = await dio.download(
        instagramUrl,
        filePath,
        queryParameters: {"url": url},
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100);
            // Update download progress provider
            ref.read(downloadProgressProvider.notifier).update(progress);
          }
        },
      );

      // Check response status
      if (response.statusCode != 200) {
        throw Exception("Download failed.");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> downloadTiktok(String url, WidgetRef ref) async {
    try {
      if (!isValidTikTokUrl(url)) {
        throw Exception("Invalid tiktok video URL.");
      }

      final dio = DioService.dio;
      final filePath = await getFileSavePath(FileType.video);

      final response = await dio.download(
        tiktokUrl,
        filePath,
        queryParameters: {"url": url},
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100);
            // Update download progress provider
            ref.read(downloadProgressProvider.notifier).update(progress);
          }
        },
      );

      // Check response status
      if (response.statusCode != 200) {
        throw Exception("Download failed.");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> downloadYoutubeVideo(
    String url,
    WidgetRef ref,
    FileType type,
  ) async {
    try {
      if (!isValidYouTubeUrl(url)) {
        throw Exception("Invalid youtube video URL.");
      }

      final dio = DioService.dio;
      final filePath = await getFileSavePath(type);

      final response = await dio.download(
        youtubeUrl,
        filePath,
        queryParameters: {"file_type": type.name, "url": url},
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100);
            ref.read(downloadProgressProvider.notifier).update(progress);
          }
        },
      );

      // Check response status
      if (response.statusCode != 200) {
        throw Exception("Download failed.");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
