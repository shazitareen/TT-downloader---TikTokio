import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final headers = {
    'x-rapidapi-key': '7f02dcb732mshe0adcde39d9a2b1p183a68jsn1c4b7d554208',
    'x-rapidapi-host': 'download-videos-tiktok.p.rapidapi.com',
  };
  const testUrl =
      'https://www.tiktok.com/@shaziofficial__7/video/7488057209352703278';

  try {
    print('Testing GET /');
    final res1 = await dio.get(
      'https://download-videos-tiktok.p.rapidapi.com/',
      queryParameters: {'url': testUrl},
      options: Options(headers: headers),
    );
    print('GET / Success: \n${res1.data}');
  } catch (e) {
    print('GET / Error: $e');
  }

  try {
    print('\nTesting POST /');
    final res2 = await dio.post(
      'https://download-videos-tiktok.p.rapidapi.com/',
      data: {'url': testUrl, 'hd': '1'},
      options: Options(headers: headers),
    );
    print('POST / Success: \n${res2.data}');
  } catch (e) {
    print('POST / Error: $e');
  }

  try {
    print('\nTesting GET /video');
    final res4 = await dio.get(
      'https://download-videos-tiktok.p.rapidapi.com/video',
      queryParameters: {'url': testUrl},
      options: Options(headers: headers),
    );
    print('GET /video Success: \n${res4.data}');
  } catch (e) {
    print('GET /video Error: $e');
  }

  try {
    print('\nTesting GET /download');
    final res5 = await dio.get(
      'https://download-videos-tiktok.p.rapidapi.com/download',
      queryParameters: {'url': testUrl},
      options: Options(headers: headers),
    );
    print('GET /download Success: \n${res5.data}');
  } catch (e) {
    print('GET /download Error: $e');
  }
}
