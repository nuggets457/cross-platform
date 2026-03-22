import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../services/nasa_api.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/card_widget.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Map<String, dynamic>>> _photos;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  final List<String> _selectedCategories = [];
  String _sortOption = 'newest'; // 'newest', 'oldest', 'title_asc'

  @override
  void initState() {
    super.initState();
    // Load photos once when the screen opens so rebuilds do not refetch them.
    _photos = NasaService.fetchApodGalleryPhotos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterPhotos(List<Map<String, dynamic>> photos) {
    if (_searchQuery.trim().isEmpty) {
      return photos;
    }

    final query = _searchQuery.toLowerCase().trim();

    return photos.where((photo) {
      // `search_text` is assembled by the service from the APOD metadata so
      // one search box can cover title, date, and description content.
      final searchable = (photo['search_text'] as String? ?? '').toLowerCase();
      return searchable.contains(query);
    }).toList(growable: false);
  }

  String _getPhotoCategory(Map<String, dynamic> photo) {
    final title = (photo['title'] as String? ?? '').toLowerCase();
    final description = (photo['description'] as String? ?? '').toLowerCase();
    final searchText = title + ' ' + description;

    if (searchText.contains('galaxy') || searchText.contains('galaxies')) {
      return 'Galaxy';
    } else if (searchText.contains('planet') || searchText.contains('planets')) {
      return 'Planets';
    } else if (searchText.contains('moon') || searchText.contains('lunar')) {
      return 'Moon';
    } else if (searchText.contains('comet') || searchText.contains('asteroid') || searchText.contains('meteor')) {
      return 'Space';
    }
    return 'Space'; // Default category
  }

  List<Map<String, dynamic>> _applyFiltersAndSort(List<Map<String, dynamic>> photos) {
    // Apply category filter
    List<Map<String, dynamic>> filtered = photos;
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((photo) => _selectedCategories.contains(_getPhotoCategory(photo)))
          .toList(growable: false);
    }

    // Apply sorting
    if (_sortOption == 'newest') {
      // Most recent first (date descending)
      filtered.sort((a, b) {
        final dateA = a['subtitle'] as String? ?? '';
        final dateB = b['subtitle'] as String? ?? '';
        return dateB.compareTo(dateA);
      });
    } else if (_sortOption == 'oldest') {
      // Oldest first (date ascending)
      filtered.sort((a, b) {
        final dateA = a['subtitle'] as String? ?? '';
        final dateB = b['subtitle'] as String? ?? '';
        return dateA.compareTo(dateB);
      });
    } else if (_sortOption == 'title_asc') {
      // Title A-Z
      filtered.sort((a, b) {
        final titleA = (a['title'] as String? ?? '').toLowerCase();
        final titleB = (b['title'] as String? ?? '').toLowerCase();
        return titleA.compareTo(titleB);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);

    return Scaffold(
      body: ScreenFrame(
        child: Column(
          children: [
            ScreenHeader(
              title: 'GALLERY',
              subtitle: 'Recent NASA Astronomy Picture of the Day image archive',
              onBack: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.home,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by title, date, or description',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: _showFavoritesOnly
                      ? 'Show all images'
                      : 'Show favorites only',
                  onPressed: () {
                    setState(() {
                      _showFavoritesOnly = !_showFavoritesOnly;
                    });
                  },
                  icon: Icon(
                    _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(' Galaxy', 'Galaxy'),
                  const SizedBox(width: 8),
                  _buildFilterChip(' Planets', 'Planets'),
                  const SizedBox(width: 8),
                  _buildFilterChip(' Moon', 'Moon'),
                  const SizedBox(width: 8),
                  _buildFilterChip(' Space', 'Space'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Sort Options
            Row(
              children: [
                const Text('Sort: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortButton('Newest → Oldest', 'newest'),
                        const SizedBox(width: 8),
                        _buildSortButton('Oldest → Newest', 'oldest'),
                        const SizedBox(width: 8),
                        _buildSortButton('Title A–Z', 'title_asc'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _photos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    // Surface the exact exception so API or connectivity issues
                    // are easier to diagnose on the device.
                    return Center(
                      child: Text(
                        'Unable to load APOD images right now.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final photos = snapshot.data ?? <Map<String, dynamic>>[];
                  final searchedPhotos = _filterPhotos(photos);
                  final filteredAndSortedPhotos = _applyFiltersAndSort(searchedPhotos);
                  final filteredPhotos = _showFavoritesOnly
                      ? filteredAndSortedPhotos
                          .where(
                            (photo) => appState.isFavorite(
                              photo['img_src'] as String? ?? '',
                            ),
                          )
                          .toList(growable: false)
                      : filteredAndSortedPhotos;

                  if (photos.isEmpty) {
                    return const Center(
                      child: Text('No APOD images were returned from NASA.'),
                    );
                  }

                  if (filteredPhotos.isEmpty) {
                    return Center(
                      child: Text(
                        _showFavoritesOnly
                            ? 'No favorite images match this view.'
                            : 'No images match "$_searchQuery".',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Use the selected grid count from app state
                      final crossAxisCount = appState.galleryGridCount;

                      return GridView.builder(
                        itemCount: filteredPhotos.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.74,
                        ),
                        itemBuilder: (context, index) {
                          final photo = filteredPhotos[index];
                          final imageUrl = photo['img_src'] as String? ?? '';
                          final title =
                              photo['title'] as String? ?? 'NASA APOD Image';
                          final subtitle =
                              photo['subtitle'] as String? ?? 'Unknown date';
                          final photoId = photo['id']?.toString() ?? subtitle;
                          final description = photo['description'] as String? ?? '';

                          return _GalleryPhotoCard(
                            imageUrl: imageUrl,
                            title: title,
                            subtitle: subtitle,
                            isFavorite: appState.isFavorite(imageUrl),
                            onTap: () => _showPhotoDetails(
                              context,
                              imageUrl: imageUrl,
                              title: title,
                              subtitle: subtitle,
                              photoId: photoId,
                              description: description,
                              isFavorite: appState.isFavorite(imageUrl),
                              onFavorite: () {
                                appState.toggleFavorite(imageUrl);
                                Navigator.pop(context);
                              },
                            ),
                            // Favorites are stored globally in AppState so the
                            // Settings page can list them later.
                            onFavorite: () => appState.toggleFavorite(imageUrl),
                            onShare: () async {
                              await Clipboard.setData(
                                ClipboardData(text: imageUrl),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image URL copied for sharing.'),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const AppBottomNav(currentRoute: AppRoutes.gallery),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String category) {
    final isSelected = _selectedCategories.contains(category);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }

  Widget _buildSortButton(String label, String value) {
    final isSelected = _sortOption == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortOption = value;
          });
        }
      },
    );
  }

  void _showPhotoDetails(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String subtitle,
    required String photoId,
    required String description,
    required bool isFavorite,
    required VoidCallback onFavorite,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.55,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        height: 260,
                        errorBuilder: (_, _, _) => const SizedBox(
                          height: 260,
                          child: Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Date: $subtitle\nArchive tag: $photoId',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description.isEmpty
                          ? 'No additional description was provided for this image.'
                          : description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: onFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          label: Text(
                            isFavorite ? 'Remove Favorite' : 'Add Favorite',
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: imageUrl),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image URL copied for sharing.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GalleryPhotoCard extends StatelessWidget {
  const _GalleryPhotoCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onShare,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE1E1E1);
    final textColor = isDark ? Colors.white : Colors.black;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textColor, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: onShare,
                  icon: Icon(Icons.share_outlined, color: textColor, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    // NetworkImage handles the live NASA thumbnail URL returned by
                    // the service. The error/loading builders keep the card stable.
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: textColor,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
