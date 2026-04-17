/// API Configuration for TikTok Downloader
/// 
/// TO SWITCH TO CLIENT'S API:
/// 1. Update [baseUrl] to the client's endpoint.
/// 2. Update [apiKey] and [apiHost] if they use RapidAPI or custom headers.
/// 3. Set [useMockData] to false for production.
class ApiConfig {
  /// Toggle this to [true] to test UI without making real network calls.
  static const bool useMockData = false;

  /// The base URL for the TikTok Video Info API.
  static const String baseUrl = 'https://tiktok-downloader-download-tiktok-videos-without-watermark.p.rapidapi.com/';

  /// RapidAPI Key (Updated to the current provided key)
  static const String apiKey = '7f02dcb732mshe0adcde39d9a2b1p183a68jsn1c4b7d554208';

  /// RapidAPI Host (Updated to the latest host)
  static const String apiHost = 'tiktok-downloader-download-tiktok-videos-without-watermark.p.rapidapi.com';

  /// Helper to get localized headers
  static Map<String, String> get headers => {
    'x-rapidapi-key': apiKey,
    'x-rapidapi-host': apiHost,
    'Content-Type': 'application/json',
  };
}
