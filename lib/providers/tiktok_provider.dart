import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/api_config.dart';
import '../core/api_service.dart';

part 'tiktok_provider.g.dart';

class TikTokVideoInfo {
  final String title;
  final String author;
  final String thumbnailUrl;
  final String noWatermarkUrl;
  final String watermarkUrl;
  final String musicUrl;

  TikTokVideoInfo({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.noWatermarkUrl,
    required this.watermarkUrl,
    required this.musicUrl,
  });

  factory TikTokVideoInfo.fromJson(Map<String, dynamic> json) {
    // The new API returns fields as lists of strings
    final List<dynamic>? videos = json['video'];
    final List<dynamic>? authors = json['author'];
    final List<dynamic>? covers = json['cover'];
    final List<dynamic>? musicList = json['music'];
    final List<dynamic>? descriptions = json['description'];
    final List<dynamic>? watermarkVideos = json['OriginalWatermarkedVideo'];

    return TikTokVideoInfo(
      title: (descriptions != null && descriptions.isNotEmpty) ? descriptions[0].toString() : 'No Title',
      author: (authors != null && authors.isNotEmpty) ? authors[0].toString() : 'Unknown Author',
      thumbnailUrl: (covers != null && covers.isNotEmpty) ? covers[0].toString() : '',
      noWatermarkUrl: (videos != null && videos.isNotEmpty) ? videos[0].toString() : '',
      watermarkUrl: (watermarkVideos != null && watermarkVideos.isNotEmpty) ? watermarkVideos[0].toString() : '',
      musicUrl: (musicList != null && musicList.isNotEmpty) ? musicList[0].toString() : '',
    );
  }

  factory TikTokVideoInfo.mock() {
    return TikTokVideoInfo(
      title: "How to bake a cake (Mock)",
      author: "@chef_mock",
      thumbnailUrl: "https://picsum.photos/400/800",
      noWatermarkUrl: "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
      watermarkUrl: "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
      musicUrl: "https://www.sample-videos.com/audio/mp3/crowd-cheering.mp3",
    );
  }
}

@riverpod
class TikTokNotifier extends _$TikTokNotifier {
  final ApiService _apiService = ApiService();

  @override
  AsyncValue<TikTokVideoInfo?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> fetchVideoInfo(String url) async {
    state = const AsyncValue.loading();

    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 2));
      state = AsyncValue.data(TikTokVideoInfo.mock());
      return;
    }

    try {
      final data = await _apiService.fetchVideoInfo(url);
      state = AsyncValue.data(TikTokVideoInfo.fromJson(data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
@riverpod
class TikTokSearchNotifier extends _$TikTokSearchNotifier {
  final ApiService _apiService = ApiService();

  int _currentOffset = 0;
  String _currentKeywords = '';
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  @override
  AsyncValue<List<TikTokVideoInfo>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> search(String keywords, {int count = 10}) async {
    _currentKeywords = keywords;
    _currentOffset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncValue.loading();

    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 2));
      state = AsyncValue.data([
        TikTokVideoInfo.mock(),
        TikTokVideoInfo.mock(),
        TikTokVideoInfo.mock(),
      ]);
      return;
    }

    try {
      final response = await _apiService.searchVideos(keywords, count: count, offset: _currentOffset);
      final List<dynamic> videosJson = response['data'] ?? [];
      final videos = videosJson.map((v) => TikTokVideoInfo.fromJson(v as Map<String, dynamic>)).toList();
      _hasMore = videos.length >= count;
      state = AsyncValue.data(videos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore({int count = 10}) async {
    if (!_hasMore || state.isLoading || _isLoadingMore) return;
    
    _isLoadingMore = true;
    // Trigger UI update using state as-is to show loading indicator if needed
    state = AsyncValue.data(state.value ?? []); 
    
    final currentState = state.value ?? [];
    _currentOffset += count;

    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data([...currentState, TikTokVideoInfo.mock(), TikTokVideoInfo.mock()]);
      _isLoadingMore = false;
      return;
    }

    try {
      final response = await _apiService.searchVideos(_currentKeywords, count: count, offset: _currentOffset);
      final List<dynamic> videosJson = response['data'] ?? [];
      final newVideos = videosJson.map((v) => TikTokVideoInfo.fromJson(v as Map<String, dynamic>)).toList();
      _hasMore = newVideos.length >= count;
      state = AsyncValue.data([...currentState, ...newVideos]);
    } catch (e) {
      _currentOffset -= count;
      // You could set state error here if you want to show it, or just ignore.
    } finally {
      _isLoadingMore = false;
      // Re-trigger build to remove loading indicator
      state = AsyncValue.data(state.value ?? []); 
    }
  }
}
