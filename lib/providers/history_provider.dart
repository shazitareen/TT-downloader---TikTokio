import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'settings_provider.dart';

part 'history_provider.g.dart';

class HistoryItem {
  final String title;
  final String author;
  final String thumbnailUrl;
  final String? localThumbnailPath;
  final DateTime date;
  final String videoPath;

  HistoryItem({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.date,
    required this.videoPath,
    this.localThumbnailPath,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'thumbnailUrl': thumbnailUrl,
    'localThumbnailPath': localThumbnailPath,
    'date': date.toIso8601String(),
    'videoPath': videoPath,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    title: json['title'],
    author: json['author'],
    thumbnailUrl: json['thumbnailUrl'],
    date: DateTime.parse(json['date']),
    videoPath: json['videoPath'],
    localThumbnailPath: json['localThumbnailPath'],
  );
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  static const _key = 'download_history';

  @override
  Future<List<HistoryItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    var items = data.map((e) => HistoryItem.fromJson(jsonDecode(e))).toList();
    
    // Auto-clean check
    final settingsAsync = ref.read(settingsNotifierProvider);
    if (settingsAsync is AsyncData<SettingsState>) {
      final settings = settingsAsync.value;
      if (settings.isAutoCleanEnabled) {
        items = await _performAutoClean(items, settings.autoCleanDays);
      }
    }
    
    return items;
  }

  Future<List<HistoryItem>> _performAutoClean(List<HistoryItem> items, int days) async {
    final now = DateTime.now();
    final threshold = now.subtract(Duration(days: days));
    
    final toKeep = <HistoryItem>[];
    bool changed = false;

    for (var item in items) {
      if (item.date.isBefore(threshold)) {
        // Delete physical files
        try {
          final videoFile = File(item.videoPath);
          if (await videoFile.exists()) {
            await videoFile.delete();
          }
          if (item.localThumbnailPath != null) {
            final thumbFile = File(item.localThumbnailPath!);
            if (await thumbFile.exists()) {
              await thumbFile.delete();
            }
          }
        } catch (e) {
          // Log or ignore delete error
        }
        changed = true;
      } else {
        toKeep.add(item);
      }
    }

    if (changed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        toKeep.map((e) => jsonEncode(e.toJson())).toList(),
      );
    }
    
    return toKeep;
  }

  Future<void> addItem(HistoryItem item) async {
    final current = await future;
    final updated = [item, ...current];
    state = AsyncValue.data(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> removeItem(int index) async {
    final current = await future;
    final item = current[index];
    
    // Delete physical files
    try {
      final videoFile = File(item.videoPath);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }
      if (item.localThumbnailPath != null) {
        final thumbFile = File(item.localThumbnailPath!);
        if (await thumbFile.exists()) {
          await thumbFile.delete();
        }
      }
    } catch (e) {
      // Ignore
    }

    final updated = List<HistoryItem>.from(current)..removeAt(index);
    state = AsyncValue.data(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> clearHistory() async {
    state = const AsyncValue.data([]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
