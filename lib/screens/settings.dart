import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importing app-level configurations and shared state
import '../app.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/card_widget.dart';
import '../widgets/logo_widget.dart';

/// Settings screen where users can customize app behavior
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Access global app state
    final appState = AppScope.of(context);

    // Get favorite images list (immutable copy)
    final favorites = appState.favoritePhotoUrls.toList(growable: false);

    // Adjust card color based on theme (light/dark)
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2E2E2E)
        : const Color(0xFFE1E1E1);

    return Scaffold(
      body: ScreenFrame(
        child: Column(
          children: [
            /// Header section with title and back navigation
            ScreenHeader(
              title: 'SETTINGS',
              subtitle:
                  'Customize appearance, alerts, favorites, and app info.',
              onBack: () => Navigator.pop(context), // Go back safely
            ),

            const SizedBox(height: 18),

            /// AETHERION Logo
            SizedBox(
              width: 120,
              height: 120,
              child: AetherionLogo(size: 120),
            ),

            const SizedBox(height: 18),

            /// Main scrollable settings content
            Expanded(
              child: ListView(
                children: [
                  /// ================= Appearance Section =================
                  _SectionCard(
                    color: cardColor,
                    title: 'Appearance',
                    children: [
                      /// Theme Selection Dropdown
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ThemeMode>(
                        value: appState.themeMode,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setThemeMode(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Accent Color Selection Dropdown
                      Text(
                        'Accent Color',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AppAccentColor>(
                        value: appState.accentColor,
                        items: const [
                          DropdownMenuItem(
                            value: AppAccentColor.blue,
                            child: Text('Blue'),
                          ),
                          DropdownMenuItem(
                            value: AppAccentColor.purple,
                            child: Text('Purple'),
                          ),
                          DropdownMenuItem(
                            value: AppAccentColor.red,
                            child: Text('Red'),
                          ),
                          DropdownMenuItem(
                            value: AppAccentColor.teal,
                            child: Text('Teal'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setAccentColor(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Font Size Selection Dropdown
                      Text(
                        'Font Size',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AppFontSize>(
                        value: appState.fontSize,
                        items: const [
                          DropdownMenuItem(
                            value: AppFontSize.small,
                            child: Text('Small'),
                          ),
                          DropdownMenuItem(
                            value: AppFontSize.medium,
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: AppFontSize.large,
                            child: Text('Large'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setFontSize(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Gallery Grid Selection Dropdown
                      Text(
                        'Gallery Grid',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: appState.galleryGridCount,
                        items: const [
                          DropdownMenuItem(
                            value: 2,
                            child: Text('2 Columns'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('3 Columns'),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text('4 Columns'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setGalleryGridCount(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// UI Style Toggle
                      Text(
                        'UI Style',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: appState.uiStyle,
                        items: const [
                          DropdownMenuItem(
                            value: 'soft',
                            child: Text('Soft'),
                          ),
                          DropdownMenuItem(
                            value: 'sharp',
                            child: Text('Sharp'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setUIStyle(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Animations Toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Animations'),
                        value: appState.animationsEnabled,
                        onChanged: (value) => appState.setAnimationsEnabled(value),
                      ),

                      /// Background Effects Toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Background Effects'),
                        value: appState.backgroundEffectsEnabled,
                        onChanged: (value) =>
                            appState.setBackgroundEffectsEnabled(value),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ================= Notifications Section =================
                  _SectionCard(
                    color: cardColor,
                    title: 'Notifications',
                    children: [
                      /// Master switch for notifications
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable Notifications'),
                        value: appState.notificationsEnabled,
                        onChanged: appState.setNotificationsEnabled,
                      ),

                      /// Breaking news alerts
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Breaking News Alerts'),
                        value: appState.breakingSpaceNewsAlerts,
                        onChanged: appState.notificationsEnabled
                            ? appState.setBreakingSpaceNewsAlerts
                            : null,
                      ),

                      /// Sound toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Sound'),
                        value: appState.soundEnabled,
                        onChanged: appState.notificationsEnabled
                            ? appState.setSoundEnabled
                            : null,
                      ),

                      /// Vibration toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Vibration'),
                        value: appState.vibrationEnabled,
                        onChanged: appState.notificationsEnabled
                            ? appState.setVibrationEnabled
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ================= Favorites Section =================
                  _SectionCard(
                    color: cardColor,
                    title: 'Favorites',
                    children: [
                      /// Show summary text
                      Text(
                        favorites.isEmpty
                            ? 'No favorites yet.'
                            : '${favorites.length} favorite image(s).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      const SizedBox(height: 12),

                      /// Action buttons for favorites
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          /// Clear all favorites
                          FilledButton.icon(
                            onPressed: favorites.isEmpty
                                ? null
                                : () {
                                    appState.clearFavorites();
                                    _showMessage(context,
                                        'All favorites were cleared.');
                                  },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear All'),
                          ),

                          /// Copy/share links
                          OutlinedButton.icon(
                            onPressed: favorites.isEmpty
                                ? null
                                : () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                          text: favorites.join('\n')),
                                    );
                                    if (!context.mounted) return;
                                    _showMessage(context,
                                        'Links copied for sharing.');
                                  },
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ================= About Section =================
                  _SectionCard(
                    color: cardColor,
                    title: 'About',
                    children: [
                      /// App description
                      Text(
                        'AETHERION is a space and Mars exploration app designed to bring the cosmos closer to you. The initial wireframe was created 3 months ago, and has since been enhanced with an intuitive interface, real-time Mars weather data, NASA APOD integration, and interactive gallery features.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.6,
                            ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),

                      /// Info rows
                      _InfoRow(label: 'Version', value: '26.3'),
                      _InfoRow(label: 'Developer', value: 'Dulina Kodagoda'),
                      _InfoRow(
                          label: 'Contact',
                          value: 'kodagodabtcdulina@gmail.com'),
                      _InfoRow(
                          label: 'Design',
                          value: 'Material 3 Design System'),
                      const SizedBox(height: 12),

                      /// Key features
                      Text(
                        'Key Features:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _bulletPoint(' Real-time Mars weather data'),
                      _bulletPoint(' NASA APOD (Astronomy Picture of Day)'),
                      _bulletPoint(' Customizable appearance & themes'),
                      _bulletPoint(' Favorites gallery management'),
                      _bulletPoint('Smart notifications'),
                      const SizedBox(height: 12),

                      /// Action buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                const ClipboardData(
                                    text:
                                        'kodagodabtcdulina@gmail.com'),
                              );
                              if (!context.mounted) return;
                              _showMessage(context,
                                  'Email copied to clipboard.');
                            },
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Contact Dev'),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              _showMessage(
                                  context,
                                  'Version 26.3\nLast updated: March 2026\n\n'
                                  'New features include Mars weather cards, improved gallery filtering, and enhanced appearance settings.');
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Changelog'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Bottom navigation bar
            const AppBottomNav(currentRoute: AppRoutes.settings),
          ],
        ),
      ),
    );
  }

  /// Show snackbar message
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Build bullet point for feature list
Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text('•', style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

/// Reusable section card widget
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.color,
    required this.title,
    required this.children,
  });

  final Color color;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// Row widget for displaying label-value pairs
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
