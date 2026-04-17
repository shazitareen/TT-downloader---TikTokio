import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/tiktok_provider.dart';
import '../screens/result_screen.dart';

class SearchResultsSheet extends ConsumerStatefulWidget {
  const SearchResultsSheet({super.key});

  @override
  ConsumerState<SearchResultsSheet> createState() => _SearchResultsSheetState();
}

class _SearchResultsSheetState extends ConsumerState<SearchResultsSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(tikTokSearchNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(tikTokSearchNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Search Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: searchState.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return const Center(child: Text("No videos found."));
                }
                final notifier = ref.watch(tikTokSearchNotifierProvider.notifier);
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: videos.length + (notifier.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == videos.length) {
                      return const Center(child: SpinKitThreeBounce(color: Colors.grey, size: 24));
                    }
                    final video = videos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // close sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResultScreen(videoInfo: video)),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey, child: const Icon(Icons.video_library)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                                gradient: LinearGradient(
                                  colors: [Colors.black87, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 40),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}
