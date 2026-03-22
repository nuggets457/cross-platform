import 'package:flutter/material.dart';
import 'dart:async';

import '../app.dart';
import '../services/nasa_api.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _featuredPhotos;
  int _elysiumImageIndex = 0;
  late Timer _rotationTimer;
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _featuredPhotos = NasaService.fetchPhotos();
    
    // Initialize swipe animation controller
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _swipeAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut));
    
    // Start auto-rotation for Elysium card - changes image every 5 seconds
    _rotationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _featuredPhotos.then((photos) {
        if (photos.isNotEmpty && mounted) {
          // Play swipe animation
          _swipeController.forward().then((_) {
            setState(() {
              _elysiumImageIndex = (_elysiumImageIndex + 1) % photos.length;
            });
            _swipeController.reset();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationTimer.cancel();
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenFrame(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'AETHERION',
              subtitle:
                  '"We should go boldly where humanity has not gone before."',
            ),
            const SizedBox(height: 18),
            // These top cards act as the main content navigation for the
            // weather-style pages in the assignment design.
            InfoCard(
              title: 'Wind',
              subtitle: 'Average gusts, calm periods, and atmospheric motion',
              accentColor: const Color.fromARGB(255, 255, 255, 255),
              onTap: () => Navigator.pushNamed(context, AppRoutes.wind),
            ),
            const SizedBox(height: 10),
            InfoCard(
              title: 'Pressure',
              subtitle: 'Surface pressure shifts and seasonal behavior',
              accentColor: const Color.fromARGB(255, 255, 255, 255),
              onTap: () => Navigator.pushNamed(context, AppRoutes.pressure),
            ),
            const SizedBox(height: 10),
            InfoCard(
              title: 'Temperature',
              subtitle: 'Day, night, and daily thermal range of Mars',
              accentColor: const Color.fromARGB(255, 255, 255, 255),
              onTap: () => Navigator.pushNamed(context, AppRoutes.temperature),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _featuredPhotos,
                builder: (context, snapshot) {
                  final photos = snapshot.data ?? const <Map<String, dynamic>>[];
                  final currentPhoto = photos.isNotEmpty 
                      ? photos[_elysiumImageIndex % photos.length]
                      : null;
                  final elysiumImage = currentPhoto?['img_src'] as String?;
                  final imageDescription = currentPhoto?['description'] as String? ?? '';

                  return SlideTransition(
                    position: _swipeAnimation,
                    child: Row(
                      children: [
                        // The lower feature cards open the richer detail screens with swipe animation
                        FeatureCard(
                          title: 'Elysium Planitia',
                          caption: 'Featured region with image, facts, and audio bar',
                          imageUrl: elysiumImage,
                          description: imageDescription,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.elysium,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const AppBottomNav(currentRoute: AppRoutes.home),
          ],
        ),
      ),
    );
  }
}
