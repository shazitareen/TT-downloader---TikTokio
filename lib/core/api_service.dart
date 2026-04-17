import 'package:dio/dio.dart';
import 'api_config.dart';

/// Service to handle network requests for TikTok Video Info
/// 
/// TO SWITCH TO CLIENT'S API:
/// 1. Update [fetchVideoInfo] method if the client uses GET instead of POST.
/// 2. If the client's JSON matches a different key structure, update the parsing.
class ApiService {
  final Dio _dio = Dio();

  String _handleDioError(DioException e) {
    if (e.response != null) {
      if (e.response?.statusCode == 404) {
        return 'API Endpoint not found (404). The requested URL path does not exist on this host.';
      } else if (e.response?.statusCode == 502) {
        return 'Bad Gateway (502). The API provider is currently unreachable.';
      }
      final msg = e.response?.data is Map 
          ? (e.response?.data['message'] ?? e.response?.data['error']) 
          : null;
      return 'API Error (${e.response?.statusCode}): ${msg ?? e.message}';
    } else {
      return 'Network Error: ${e.message}';
    }
  }

  Future<Map<String, dynamic>> fetchVideoInfo(String tiktokUrl) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}vid/index', 
        queryParameters: {
          'url': tiktokUrl,
        },
        options: Options(
          headers: ApiConfig.headers,
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Searches for TikTok videos by keywords.
  /// NOTE: This endpoint is not available on the current RapidAPI host.
  Future<Map<String, dynamic>> searchVideos(String keywords, {int count = 10, int offset = 0}) async {
    throw UnimplementedError('Search is not supported by the current API host.');
  }
}
