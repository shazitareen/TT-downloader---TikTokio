import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildSectionHeader('Appearance'),
            SwitchListTile(
              secondary: Icon(
                settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: settings.isDarkMode ? Colors.orange : Colors.grey,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark themes'),
              value: settings.isDarkMode,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier).toggleDarkMode();
              },
            ),
            const Divider(),
            _buildSectionHeader('Storage Management'),
            SwitchListTile(
              secondary: Icon(
                Icons.cleaning_services,
                color: settings.isAutoCleanEnabled ? Colors.blue : Colors.grey,
              ),
              title: const Text('Auto-Clean Downloads'),
              subtitle: Text('Automatically delete files older than ${settings.autoCleanDays} days'),
              value: settings.isAutoCleanEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier).toggleAutoClean();
              },
            ),
            if (settings.isAutoCleanEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clean files older than:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Slider(
                      value: settings.autoCleanDays.toDouble(),
                      min: 7,
                      max: 97,
                      divisions: 3, // 7, 37, 67, 97 -> mapping 7, 30, 60, 90
                      label: '${settings.autoCleanDays} days',
                      onChanged: (value) {
                        // Map slider value to common day increments
                        int days = 30;
                        if (value < 20) {
                          days = 7;
                        } else if (value < 50) {
                          days = 30;
                        } else if (value < 80) {
                          days = 60;
                        } else {
                          days = 90;
                        }
                        ref.read(settingsNotifierProvider.notifier).setAutoCleanDays(days);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('7d', style: TextStyle(fontSize: 10)),
                          Text('30d', style: TextStyle(fontSize: 10)),
                          Text('60d', style: TextStyle(fontSize: 10)),
                          Text('90d', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            _buildSectionHeader('Support'),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Visit TikTokio.net'),
              subtitle: const Text('Download TikTok videos online'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl('https://tiktokio.net/'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              onTap: () => _launchUrl('https://tiktokio.net/terms-of-service'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () => _launchUrl('https://tiktokio.net/privacy-policy'),
            ),
            const Divider(),
            _buildSectionHeader('App Info'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              trailing: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.code),
              title: Text('Developed with Flutter & Riverpod'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
