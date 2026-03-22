/// Elysium Planitia Region Detail Screen
/// 
/// Displays comprehensive information about the Elysium Planitia region on Mars
/// including a carousel of high-resolution NASA rover imagery with navigation
/// controls and favorites management. Users can browse rover photos, view details,
/// and save their favorite images to the app's favorites collection.

import 'package:flutter/material.dart';
import 'dart:async';

import '../app.dart';
import '../services/nasa_api.dart';
import '../state/app_state.dart';
import '../widgets/animation_widgets.dart';
import '../widgets/card_widget.dart';

/// Screen displaying Elysium Planitia region details with NASA rover imagery
/// Features an interactive image carousel with navigation and favorites
class ElysiumScreen extends StatefulWidget {
  const ElysiumScreen({super.key});

  @override
  State<ElysiumScreen> createState() => _ElysiumScreenState();
}

/// State management for Elysium screen - handles image navigation and data
class _ElysiumScreenState extends State<ElysiumScreen> {
  /// Future for fetching NASA rover photos from API
  late Future<List<Map<String, dynamic>>> _photos;
  /// Tracks current image position in carousel (uses modulo for looping)
  int _currentImageIndex = 0;
  /// Timer for auto-rotating images every 7 seconds
  late Timer _autoRotateTimer;

  @override
  void initState() {
    super.initState();
    // Load NASA rover photos on screen initialization
    _photos = NasaService.fetchPhotos();
    
    // Start auto-rotation timer - changes image every 7 seconds
    _autoRotateTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      _photos.then((photos) {
        if (photos.isNotEmpty && mounted) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % photos.length;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _autoRotateTimer.cancel();
    super.dispose();
  }

  /// Builds the Elysium Planitia region detail screen with image carousel
  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final animationsEnabled = appState.animationsEnabled;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.orange.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
          ScreenFrame(
            child: Column(
              children: [
                FadeInUp(
                  enabled: animationsEnabled,
                  child: ScreenHeader(
                    title: 'Elysium Planitia',
                    subtitle:
                        'A smooth volcanic plain and one of the most studied regions on Mars.',
                    onBack: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Image carousel section - displays NASA rover photos with auto-rotation
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _photos,
                  builder: (context, snapshot) {
                    final photos = snapshot.data ?? const <Map<String, dynamic>>[];
                    if (photos.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ScaleIn(
                      enabled: animationsEnabled,
                      child: Column(
                        children: [
                          ImagePanel(
                            imageUrl: photos.isNotEmpty
                                ? photos[_currentImageIndex % photos.length]
                                    ['img_src'] as String?
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // Combined description and details box
                          FadeInUp(
                            enabled: animationsEnabled,
                            delay: 50,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF2E2E2E)
                                    : const Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Elysium Region Imagery',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${_currentImageIndex + 1}/${photos.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final imageUrl = photos
                                              .isNotEmpty
                                              ? photos[_currentImageIndex %
                                                  photos.length]['img_src']
                                              : null;
                                          if (imageUrl != null) {
                                            AppScope.of(context)
                                                .toggleFavorite(imageUrl);
                                            setState(() {});
                                          }
                                        },
                                        child: Icon(
                                          AppScope.of(context).isFavorite(
                                            photos.isNotEmpty
                                                ? photos[_currentImageIndex %
                                                    photos.length]['img_src']
                                                : null,
                                          )
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'High-resolution imagery captured by NASA rovers exploring the Elysium Planitia region. This collection showcases the geological formations, terrain features, and atmospheric conditions across one of Mars\'s most significant planetary regions. Each image provides valuable insights into surface composition and topography.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          height: 1.5,
                                        ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                // Description section
                FadeInUp(
                  enabled: animationsEnabled,
                  delay: 50,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2E2E2E)
                          : const Color(0xFFE1E1E1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Elysium Planitia',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Elysium Planitia is one of Mars\'s largest volcanic plains, spanning a massive region of smooth, relatively low-elevation terrain. Formed by ancient lava flows and reshaped by impact events, this region provides critical insights into Martian geology and atmospheric dynamics. Its accessibility makes it an ideal location for rover missions and detailed atmospheric studies.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.6,
                              ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
