import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TikTokioApp(),
    ),
  );
}

class TikTokioApp extends ConsumerWidget {
  const TikTokioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only what's necessary for the MaterialApp configuration
    final isDarkMode = ref.watch(settingsNotifierProvider.select((s) => s.value?.isDarkMode ?? false));
    final isLoading = ref.watch(settingsNotifierProvider.select((s) => s.isLoading));

    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'TikTokio Downloader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
