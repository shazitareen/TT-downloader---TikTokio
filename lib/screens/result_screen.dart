import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tiktok_provider.dart';
import '../providers/download_provider.dart';
import '../providers/history_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/error_state_widget.dart';
import 'dart:ui';

class ResultScreen extends ConsumerWidget {
  final TikTokVideoInfo videoInfo;

  const ResultScreen({super.key, required this.videoInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track active download URLs for this session to show multiple bars if started
    final activeDownloadUrls = <String>[
      videoInfo.noWatermarkUrl,
      videoInfo.watermarkUrl,
      videoInfo.musicUrl,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Options'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Thumbnail and Info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: videoInfo.thumbnailUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 220,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 220,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Image.asset(
                                  'assets/images/hd_badge.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                videoInfo.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    child: Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    videoInfo.author,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Active Downloads List
            Column(
              children: activeDownloadUrls.map((url) {
                if (url.isEmpty) return const SizedBox.shrink();
                final state = ref.watch(downloadNotifierProvider(url));
                if (state.status == DownloadStatus.downloading || state.status == DownloadStatus.completed) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: _DownloadProgressCard(state: state),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),

            // Download Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _DownloadButton(
                    label: 'Download Video (No Watermark)',
                    icon: Icons.high_quality,
                    color: const Color(0xFFE67E22),
                    onTap: () => _handleDownload(context, ref, videoInfo.noWatermarkUrl, "no_wm_${DateTime.now().millisecondsSinceEpoch}", thumbnailUrl: videoInfo.thumbnailUrl),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Download other video', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownload(BuildContext context, WidgetRef ref, String url, String fileName, {String? thumbnailUrl}) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download URL not available for this option')),
      );
      return;
    }

    final notifier = ref.read(downloadNotifierProvider(url).notifier);
    
    // Start download
    await notifier.downloadVideo(url, fileName, thumbnailUrl: thumbnailUrl);
    
    final state = ref.read(downloadNotifierProvider(url));
    
    if (context.mounted) {
      if (state.status == DownloadStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download Successful! Saved to Gallery.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Add to history
        ref.read(historyNotifierProvider.notifier).addItem(
          HistoryItem(
            title: videoInfo.title,
            author: videoInfo.author,
            thumbnailUrl: videoInfo.thumbnailUrl,
            localThumbnailPath: state.localThumbnailPath,
            date: DateTime.now(),
            videoPath: state.filePath!,
          ),
        );
      } else if (state.status == DownloadStatus.error) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: ErrorStateWidget(
              message: state.errorMessage ?? 'Unknown error occurred',
              onRetry: () {
                Navigator.pop(context);
                _handleDownload(context, ref, url, fileName);
              },
            ),
          ),
        );
      }
    }
  }
}

class _DownloadProgressCard extends StatelessWidget {
  final DownloadState state;

  const _DownloadProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isCompleted = state.status == DownloadStatus.completed;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted 
              ? Colors.green.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted ? Colors.green.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2)
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted ? "Download Complete!" : "Downloading...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18,
                            color: isCompleted ? Colors.green[700] : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isCompleted ? state.totalSizeStr : "${state.receivedSizeStr} / ${state.totalSizeStr}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8), 
                            fontSize: 14
                          ),
                        ),
                      ],
                    ),
                    if (isCompleted)
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 14,
                        child: Icon(Icons.check, color: Colors.white, size: 18),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          state.speedStr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: isCompleted ? 1.0 : state.progress,
                    minHeight: 12,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : Theme.of(context).colorScheme.primary),
                  ),
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${(state.progress * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _DownloadButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
