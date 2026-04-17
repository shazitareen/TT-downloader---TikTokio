import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

part 'download_provider.g.dart';

enum DownloadStatus { idle, downloading, completed, error }

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final String? filePath;
  final String? localThumbnailPath;
  final String? errorMessage;
  final int totalBytes;
  final int receivedBytes;
  final double speed; // in KB/s

  DownloadState({
    required this.status,
    this.progress = 0,
    this.filePath,
    this.localThumbnailPath,
    this.errorMessage,
    this.totalBytes = 0,
    this.receivedBytes = 0,
    this.speed = 0,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? filePath,
    String? localThumbnailPath,
    String? errorMessage,
    int? totalBytes,
    int? receivedBytes,
    double? speed,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
      errorMessage: errorMessage ?? this.errorMessage,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      speed: speed ?? this.speed,
    );
  }

  String get totalSizeStr => _formatBytes(totalBytes);
  String get receivedSizeStr => _formatBytes(receivedBytes);
  String get speedStr => "${speed.toStringAsFixed(1)} KB/s";

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int index = (math.log(bytes) / math.log(1024)).floor();
    return "${(bytes / math.pow(1024, index)).toStringAsFixed(1)} ${suffixes[index]}";
  }
}

@riverpod
class DownloadNotifier extends _$DownloadNotifier {
  final Dio _dio = Dio();

  @override
  DownloadState build(String downloadId) {
    return DownloadState(status: DownloadStatus.idle);
  }

  Future<void> downloadVideo(String url, String fileName, {String? thumbnailUrl}) async {
    if (url.isEmpty) {
      state = state.copyWith(status: DownloadStatus.error, errorMessage: "Download URL is empty");
      return;
    }

    state = DownloadState(status: DownloadStatus.downloading, progress: 0);
    final stopwatch = Stopwatch()..start();

    try {
      // Check for permissions
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      
      if (await Permission.photos.isDenied) {
        await Permission.photos.request();
      }

      final appDir = await getApplicationDocumentsDirectory();
      final videoFileName = "$fileName.mp4";
      final filePath = "${appDir.path}/$videoFileName";
      
      String? localThumbPath;
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        try {
          localThumbPath = "${appDir.path}/thumb_$fileName.jpg";
          await _dio.download(thumbnailUrl, localThumbPath);
        } catch (e) {
          debugPrint("Failed to download thumbnail: $e");
        }
      }

      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
            'Referer': 'https://www.tiktok.com/',
          },
        ),
        onReceiveProgress: (count, total) {
          if (total != -1) {
            final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;
            double speed = 0;
            if (elapsedSec > 0) {
              speed = (count / 1024.0) / elapsedSec; // KB/s
            }
            
            state = state.copyWith(
              progress: count / total,
              receivedBytes: count,
              totalBytes: total,
              speed: speed,
            );
          }
        },
      );

      stopwatch.stop();

      // Save to Gallery
      await Gal.putVideo(filePath);
      
      state = state.copyWith(
        status: DownloadStatus.completed, 
        filePath: filePath,
        localThumbnailPath: localThumbPath,
      );
    } catch (e) {
      state = state.copyWith(status: DownloadStatus.error, errorMessage: e.toString());
    }
  }

  void reset() {
    state = DownloadState(status: DownloadStatus.idle);
  }
}
