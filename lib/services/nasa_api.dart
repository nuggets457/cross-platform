import 'dart:convert';

import 'package:http/http.dart' as http;

class NasaService {
  static const String apiKey = 'GxD2SioOYDySHQcqSswgIvfcnRTUwiViVMoR7AJr';
  static const String _baseUrl = 'https://images-api.nasa.gov/search';
  static const String _apodBaseUrl = 'https://api.nasa.gov/planetary/apod';

  /// ================= FETCH MARS ROVER IMAGES =================
  static Future<List<Map<String, dynamic>>> fetchPhotos() async {
    final url = Uri.parse(
      '$_baseUrl?q=mars rover&media_type=image',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load NASA images (status ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    final Map<String, dynamic> collection =
        data['collection'] as Map<String, dynamic>? ?? {};

    final List<dynamic> items = collection['items'] ?? [];

    final results = <Map<String, dynamic>>[];

    for (final item in items) {
      final itemMap = item as Map<String, dynamic>;
      final dataList = itemMap['data'] ?? [];
      final links = itemMap['links'] ?? [];

      if (dataList.isEmpty || links.isEmpty) continue;

      final itemData = dataList.first;
      final firstLink = links.first;
      final imageUrl = firstLink['href'] ?? '';

      if (imageUrl.isEmpty) continue;

      final title = itemData['title'] ?? 'NASA Mars Image';
      final nasaId = itemData['nasa_id'] ?? 'Unknown';
      final dateCreated = itemData['date_created'] ?? 'Unknown date';
      final description = itemData['description'] ?? '';

      final keywords = (itemData['keywords'] ?? [])
          .map((k) => k.toString())
          .join(' ');

      results.add({
        'img_src': imageUrl,
        'title': title,
        'subtitle': dateCreated,
        'id': nasaId,
        'description': description,
        'search_text': '$title $nasaId $dateCreated $description $keywords',
      });
    }

    return results.take(30).toList(growable: false);
  }

  /// ================= FETCH APOD GALLERY =================
  static Future<List<Map<String, dynamic>>> fetchApodGalleryPhotos() async {
    final now = DateTime.now().toUtc();
    final startDate = now.subtract(const Duration(days: 59));

    final url = Uri.parse(_apodBaseUrl).replace(
      queryParameters: {
        'api_key': apiKey,
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(now),
      },
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load NASA APOD images (status ${response.statusCode})',
      );
    }

    final List<dynamic> data = json.decode(response.body);

    final results = data
        .whereType<Map<String, dynamic>>()
        .where((item) => item['media_type'] == 'image')
        .map((item) {
          final imageUrl = item['hdurl'] ?? item['url'] ?? '';
          final title = item['title'] ?? 'Astronomy Picture';
          final date = item['date'] ?? 'Unknown date';
          final description = item['explanation'] ?? '';
          final copyright = item['copyright'] ?? 'NASA';

          return {
            'img_src': imageUrl,
            'title': title,
            'subtitle': date,
            'id': date,
            'description': description,
            'copyright': copyright,
            'search_text': '$title $date $description $copyright',
          };
        })
        .where((item) => (item['img_src'] as String).isNotEmpty)
        .toList()
      ..sort((a, b) =>
          (b['subtitle'] as String).compareTo(a['subtitle'] as String));

    return results;
  }

  /// ================= NEW: FETCH INSIGHT WEATHER =================
  static Future<Map<String, dynamic>> fetchInSightWeather() async {
    final url = Uri.parse(
      'https://api.nasa.gov/insight_weather/?api_key=$apiKey&feedtype=json&ver=1.0',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load InSight weather data (status ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    // Optional safety check
    if (!data.containsKey('sol_keys')) {
      throw Exception('Invalid weather data format');
    }

    return data;
  }

  /// ================= FETCH TODAY'S APOD =================
  static Future<Map<String, dynamic>> fetchTodayApod() async {
    final url = Uri.parse(_apodBaseUrl).replace(
      queryParameters: {
        'api_key': apiKey,
      },
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load today\'s APOD (status ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final imageUrl = data['hdurl'] ?? data['url'] ?? '';
    final title = data['title'] ?? 'Astronomy Picture of the Day';
    final date = data['date'] ?? 'Unknown date';
    final description = data['explanation'] ?? '';
    final mediaType = data['media_type'] ?? 'image';
    final copyright = data['copyright'] ?? 'NASA';

    return {
      'img_src': imageUrl,
      'title': title,
      'subtitle': date,
      'description': description,
      'copyright': copyright,
      'media_type': mediaType,
      'search_text': '$title $date $description $copyright',
    };
  }

  /// ================= HELPER =================
  static String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}