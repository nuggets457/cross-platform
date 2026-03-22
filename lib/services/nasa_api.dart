import 'dart:convert';

import 'package:http/http.dart' as http;

/// NASA API service for fetching space imagery and weather data
/// 
/// This service integrates with multiple NASA APIs:
/// - NASA Images API: Mars rover imagery
/// - APOD API: Astronomy Picture of the Day
/// - InSight Weather API: Mars atmospheric data
class NasaService {
  // API key for all NASA API requests (rate limited)
  static const String apiKey = 'GxD2SioOYDySHQcqSswgIvfcnRTUwiViVMoR7AJr';
  // Base URL for NASA images search API
  static const String _baseUrl = 'https://images-api.nasa.gov/search';
  // Base URL for APOD (Astronomy Picture of the Day) API
  static const String _apodBaseUrl = 'https://api.nasa.gov/planetary/apod';

  /// ================= FETCH MARS ROVER IMAGES =================
  /// 
  /// Fetches Mars rover photos from NASA Images API
  /// Returns up to 30 images with metadata (title, date, description)
  /// Used to populate the Elysium Planitia carousel on the home screen
  static Future<List<Map<String, dynamic>>> fetchPhotos() async {
    // Construct URL to search for Mars rover images
    final url = Uri.parse(
      '$_baseUrl?q=mars rover&media_type=image',
    );

    // Make HTTP GET request with 15 second timeout
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    // Check if request was successful
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load NASA images (status ${response.statusCode})',
      );
    }

    // Parse JSON response
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    // Extract items collection from API response structure
    final Map<String, dynamic> collection =
        data['collection'] as Map<String, dynamic>? ?? {};

    // Get list of items (images) from collection
    final List<dynamic> items = collection['items'] ?? [];

    // Initialize results list to store processed images
    final results = <Map<String, dynamic>>[];

    // Process each item from the API response
    for (final item in items) {
      final itemMap = item as Map<String, dynamic>;
      // Each item contains metadata in 'data' array and image links in 'links' array
      final dataList = itemMap['data'] ?? [];
      final links = itemMap['links'] ?? [];

      // Skip items without required data or images
      if (dataList.isEmpty || links.isEmpty) continue;

      // Extract first metadata item and first image link
      final itemData = dataList.first;
      final firstLink = links.first;
      final imageUrl = firstLink['href'] ?? '';

      // Skip if no valid image URL found
      if (imageUrl.isEmpty) continue;

      // Extract image metadata
      final title = itemData['title'] ?? 'NASA Mars Image';
      final nasaId = itemData['nasa_id'] ?? 'Unknown';
      final dateCreated = itemData['date_created'] ?? 'Unknown date';
      final description = itemData['description'] ?? '';

      // Combine keywords for better searchability
      final keywords = (itemData['keywords'] ?? [])
          .map((k) => k.toString())
          .join(' ');

      // Add processed image data to results
      results.add({
        'img_src': imageUrl,           // Direct image URL
        'title': title,                // Image title
        'subtitle': dateCreated,       // Display date
        'id': nasaId,                  // Unique NASA ID
        'description': description,    // Detailed description
        'search_text': '$title $nasaId $dateCreated $description $keywords', // Searchable text
      });
    }

    // Return up to 30 most recent images
    return results.take(30).toList(growable: false);
  }

  /// ================= FETCH APOD GALLERY =================
  /// 
  /// Fetches NASA's Astronomy Picture of the Day (APOD) for the last 60 days
  /// Returns list of space/astronomy images sorted by date
  /// Used to populate the gallery screen with curated astronomy images
  static Future<List<Map<String, dynamic>>> fetchApodGalleryPhotos() async {
    // Get current date and calculate start date (60 days ago)
    final now = DateTime.now().toUtc();
    final startDate = now.subtract(const Duration(days: 59));

    // Build APOD API URL with date range and authentication
    final url = Uri.parse(_apodBaseUrl).replace(
      queryParameters: {
        'api_key': apiKey,
        'start_date': _formatDate(startDate),  // Format: YYYY-MM-DD
        'end_date': _formatDate(now),          // Format: YYYY-MM-DD
      },
    );

    // Fetch data from APOD API with timeout
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    // Handle HTTP errors
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load NASA APOD images (status ${response.statusCode})',
      );
    }

    // Parse JSON array response
    final List<dynamic> data = json.decode(response.body);

    // Process data:
    // 1. Filter to only Map entries
    // 2. Filter to only images (not videos)
    // 3. Map to standardized format
    // 4. Filter out entries without valid image URLs
    // 5. Sort by date (most recent first)
    final results = data
        .whereType<Map<String, dynamic>>()  // Parse as maps
        .where((item) => item['media_type'] == 'image')  // Only images
        .map((item) {
          // Extract image data or provide defaults
          final imageUrl = item['hdurl'] ?? item['url'] ?? '';  // Prefer HD URL
          final title = item['title'] ?? 'Astronomy Picture';
          final date = item['date'] ?? 'Unknown date';
          final description = item['explanation'] ?? '';
          final copyright = item['copyright'] ?? 'NASA';

          // Return standardized format matching other API methods
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
        .where((item) => (item['img_src'] as String).isNotEmpty)  // Valid URLs only
        .toList()
      ..sort((a, b) =>
          (b['subtitle'] as String).compareTo(a['subtitle'] as String));  // Newest first

    return results;
  }

  /// ================= NEW: FETCH INSIGHT WEATHER =================
  /// 
  /// Fetches real-time or recent Mars weather data from NASA's InSight lander
  /// Returns comprehensive atmospheric measurements including temperature, wind, pressure
  /// Used for the Data screens (Wind, Pressure, Temperature) on home and data pages
  static Future<Map<String, dynamic>> fetchInSightWeather() async {
    // Build InSight weather API endpoint with authentication
    final url = Uri.parse(
      'https://api.nasa.gov/insight_weather/?api_key=$apiKey&feedtype=json&ver=1.0',
    );

    // Fetch weather data with 15 second timeout
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    // Check for successful response
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load InSight weather data (status ${response.statusCode})',
      );
    }

    // Parse JSON response containing weather data by sol (Martian day)
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    // Validate that response contains expected sol_keys field
    if (!data.containsKey('sol_keys')) {
      throw Exception('Invalid weather data format');
    }

    // Return complete weather dataset organized by sol
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