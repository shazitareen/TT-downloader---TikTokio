import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../providers/tiktok_provider.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/search_results_sheet.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();
  String? _lastCheckedClipboard;
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to sharing intent while app is in memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        _handleSharedUrl(value.first.path);
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // Listen to sharing intent when app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _handleSharedUrl(value.first.path);
      }
    });

    // Initial check on app start for clipboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboard();
    });
  }

  void _handleSharedUrl(String value) {
    final extractedUrl = _extractUrl(value);
    if (extractedUrl != null) {
      setState(() {
        _urlController.text = extractedUrl;
      });
      _handleDownload();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentDataStreamSubscription?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();

    if (text == null || text.isEmpty || text == _lastCheckedClipboard) return;

    final extractedUrl = _extractUrl(text);
    if (extractedUrl != null) {
      _lastCheckedClipboard = text;
      _showClipboardPrompt(extractedUrl);
    }
  }

  String? _extractUrl(String text) {
    // Robust regex to find URLs
    final urlMatch = RegExp(r'(https?://[^\s]+)').firstMatch(text);
    if (urlMatch == null) return null;
    
    final url = urlMatch.group(0)!;
    // Basic check for popular video domains
    final isSupported = url.contains('tiktok.com/') || 
                       url.contains('douyin.com/') || 
                       url.contains('v.douyin.com/');
    
    return isSupported ? url : null;
  }

  bool _isUrl(String text) {
    return _extractUrl(text) != null;
  }

  void _showClipboardPrompt(String url) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.link, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'TikTok link detected on clipboard!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'PASTE',
          onPressed: () {
            setState(() {
              _urlController.text = url;
            });
            _handleDownload();
          },
        ),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _urlController.text = data.text!;
      });
    }
  }

  Future<void> _handleDownload() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a link or enter keywords')),
      );
      return;
    }

    if (_isUrl(input)) {
      // Handle direct download
      await ref.read(tikTokNotifierProvider.notifier).fetchVideoInfo(input);
      
      if (!mounted) return;
      
      final state = ref.read(tikTokNotifierProvider);
      state.whenOrNull(
        data: (info) {
          if (info != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResultScreen(videoInfo: info)),
            );
          }
        },
        error: (e, st) => _showError(e.toString()),
      );
    } else {
      // Handle search
      await ref.read(tikTokSearchNotifierProvider.notifier).search(input);
      
      if (!mounted) return;
      
      final searchState = ref.read(tikTokSearchNotifierProvider);
      searchState.whenOrNull(
        data: (videos) {
          if (videos.isNotEmpty) {
            _showSearchResults();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No videos found for these keywords')),
            );
          }
        },
        error: (e, st) => _showError(e.toString()),
      );
    }
  }

  void _showError(String message) {
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
          message: message,
          onRetry: () {
            Navigator.pop(context);
            _handleDownload();
          },
        ),
      ),
    );
  }

  void _showSearchResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchResultsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tikTokState = ref.watch(tikTokNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTokio'),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE67E22),
              ),
              child: Column(
                children: [
                  const Text(
                    'TikTokio - TikTok Video Downloader',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Without Watermark. Fast. All devices',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Input Field
                  TextField(
                    controller: _urlController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Paste Link or Search Keywords',
                      suffixIcon: _urlController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _urlController.clear()))
                        : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextButton.icon(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.paste, size: 18),
                          label: const Text('Paste'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1A73E8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: tikTokState.isLoading ? null : _handleDownload,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (tikTokState.isLoading || ref.watch(tikTokSearchNotifierProvider).isLoading)
                      ? const SpinKitThreeBounce(color: Colors.white, size: 24)
                      : const Text('Download / Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            // Info Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why use TikTokio?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.high_quality, 'High Quality', 'Download TikTok videos in original HD quality without watermark.'),
                  _buildFeatureItem(Icons.speed, 'Fast Download', 'Our servers are optimized for maximum speed, providing a premium experience.'),
                  _buildFeatureItem(Icons.devices, 'All Devices', 'Works perfectly on smartphones, tablets, and desktops.'),
                  _buildFeatureItem(Icons.security, '100% Secure', 'We do not collect your personal information or TikTok data.'),
                  const SizedBox(height: 24),
                  const Text(
                    'How to download TikTok videos?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('1. Copy the link of the TikTok video you want to download.'),
                  const Text('2. Paste the link into the input field above.'),
                  const Text('3. Click the "Download" button and choose your format.'),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      '© 2024 TikTokio - Professional TikTok Downloader',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE67E22), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
