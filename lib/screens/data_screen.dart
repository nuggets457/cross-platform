import 'package:flutter/material.dart';

import '../app.dart';
import '../services/nasa_api.dart';
import '../state/app_state.dart';
import '../widgets/animation_widgets.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/card_widget.dart';

/// Represents the three data display modes: Wind, Pressure, or Temperature
enum DataScreenType { wind, pressure, temperature }

/// DataScreen displays detailed atmospheric data for Mars regions
/// 
/// Shows real-time sensor readings from the NASA InSight mission with animated cards
/// and descriptions of atmospheric conditions in Elysium Planitia.
class DataScreen extends StatefulWidget {
  const DataScreen({
    super.key,
    required this.type,
  });

  final DataScreenType type;

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  late Future<Map<String, dynamic>> _weatherData;

  @override
  void initState() {
    super.initState();
    // Fetch Mars weather data from NASA's InSight API
    _weatherData = NasaService.fetchInSightWeather();
  }

  @override
  Widget build(BuildContext context) {
    // Get configuration based on selected data type (wind, pressure, or temperature)
    final config = _configFor(widget.type);
    // Access application state for theme and animation preferences
    final appState = AppScope.of(context);
    final animationsEnabled = appState.animationsEnabled;

    return Scaffold(
      body: Stack(
        children: [
          // Background with subtle gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.blue.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
          ScreenFrame(
            child: Column(
              children: [
                // Animated header
                _buildAnimatedHeader(context, config, animationsEnabled),
                const SizedBox(height: 18),
                // Animated stat cards
                Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _weatherData,
                      builder: (context, weatherSnapshot) {
                        final stats = weatherSnapshot.data != null
                            ? _getStatsFromWeather(weatherSnapshot.data!, widget.type)
                            : config.stats;

                        return Column(
                          children: [
                            for (int i = 0; i < stats.length; i++) ...[
                          _buildAnimatedStatCard(
                            context,
                            stats[i],
                            i,
                            animationsEnabled,
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Description card
                        _buildDescriptionCard(context, config, animationsEnabled),
                        const SizedBox(height: 14),
                        // Theme toggle card
                        _buildThemeCard(context, appState, animationsEnabled),
                        const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const AppBottomNav(currentRoute: AppRoutes.home),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an animated header with title and back navigation
  /// 
  /// Fades in from bottom with optional animation
  Widget _buildAnimatedHeader(
    BuildContext context,
    _DataScreenConfig config,
    bool animationsEnabled,
  ) {
    return FadeInUp(
      enabled: animationsEnabled,
      child: ScreenHeader(
        title: config.title,
        subtitle: config.subtitle,
        onBack: () => Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        ),
      ),
    );
  }

  /// Extracts specific metrics from NASA weather data based on data type
  /// 
  /// Parses API response for wind speed, pressure, or temperature readings.
  /// Falls back to default values if API data is unavailable.
  List<_StatValue> _getStatsFromWeather(
    Map<String, dynamic> weatherData,
    DataScreenType type,
  ) {
    try {
      final solKeys = (weatherData.keys.toList()..sort()).reversed.toList();
      if (solKeys.isEmpty) return _configFor(type).stats;

      final latestSol = solKeys.first;
      final solData = weatherData[latestSol] as Map?;

      if (solData == null) return _configFor(type).stats;

      switch (type) {
        case DataScreenType.wind:
          final windData = solData['WD'] as Map?;
          if (windData == null) return _configFor(type).stats;
          return [
            _StatValue(
              'Average Speed',
              '${(windData['av'] ?? 0).toStringAsFixed(1)} m/s',
            ),
            _StatValue(
              'Max Speed',
              '${(windData['mx'] ?? 0).toStringAsFixed(1)} m/s',
            ),
            _StatValue(
              'Min Speed',
              '${(windData['mn'] ?? 0).toStringAsFixed(1)} m/s',
            ),
          ];
        case DataScreenType.pressure:
          final pressureData = solData['PRE'] as Map?;
          if (pressureData == null) return _configFor(type).stats;
          return [
            _StatValue(
              'Average Pressure',
              '${(pressureData['av'] ?? 0).toStringAsFixed(0)} Pa',
            ),
            _StatValue(
              'Max Pressure',
              '${(pressureData['mx'] ?? 0).toStringAsFixed(0)} Pa',
            ),
            _StatValue(
              'Min Pressure',
              '${(pressureData['mn'] ?? 0).toStringAsFixed(0)} Pa',
            ),
          ];
        case DataScreenType.temperature:
          final tempData = solData['AT'] as Map?;
          if (tempData == null) return _configFor(type).stats;
          return [
            _StatValue(
              'Average Temperature',
              '${(tempData['av'] ?? 0).toStringAsFixed(1)}°C',
            ),
            _StatValue(
              'Max Temperature',
              '${(tempData['mx'] ?? 0).toStringAsFixed(1)}°C',
            ),
            _StatValue(
              'Min Temperature',
              '${(tempData['mn'] ?? 0).toStringAsFixed(1)}°C',
            ),
          ];
      }
    } catch (e) {
      return _configFor(type).stats;
    }
  }

  /// Builds individual stat cards with animations and interactive feedback
  /// 
  /// Each card shows a label and value with blue left border accent.
  /// Cards animate in sequence with staggered delays.
  Widget _buildAnimatedStatCard(
    BuildContext context,
    _StatValue stat,
    int index,
    bool animationsEnabled,
  ) {
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2E2E2E)
        : const Color(0xFFE1E1E1);

    return FadeInUp(
      enabled: animationsEnabled,
      delay: 150 + (index * 100),
      child: InteractiveScale(
        enabled: animationsEnabled,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              left: BorderSide(
                color: Colors.blue.withValues(alpha: 0.5),
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a description card explaining the atmospheric phenomena
  /// 
  /// Displays detailed text about wind, pressure, or temperature on Mars.
  Widget _buildDescriptionCard(
    BuildContext context,
    _DataScreenConfig config,
    bool animationsEnabled,
  ) {
    return FadeInUp(
      enabled: animationsEnabled,
      delay: 500,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2E2E2E)
              : const Color(0xFFE1E1E1),
        ),
        child: Text(
          config.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.6,
              ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  /// Builds a theme toggle card for dark/light mode switching
  /// 
  /// Shows current theme state with icon and label.
  Widget _buildThemeCard(
    BuildContext context,
    AppState appState,
    bool animationsEnabled,
  ) {
    return FadeInUp(
      enabled: animationsEnabled,
      delay: 600,
      child: InteractiveScale(
        enabled: animationsEnabled,
        child: InfoCard(
          title: 'Display mode',
          subtitle: appState.isDarkMode ? 'Dark mode active' : 'Light mode active',
          icon: appState.isDarkMode
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          onTap: appState.toggleTheme,
        ),
      ),
    );
  }

  /// Returns configuration data based on selected data type
  /// 
  /// Defines titles, subtitles, default statistics, and descriptions
  /// for wind, pressure, and temperature screens.
  _DataScreenConfig _configFor(DataScreenType type) {
    switch (type) {
      case DataScreenType.wind:
        return const _DataScreenConfig(
          title: 'Data Range Of Wind',
          subtitle: 'Atmospheric motion across the Elysium region',
          stats: [
            _StatValue('Average speed', '8.8 m/s (15.2 mph)'),
            _StatValue('Peak gusts', 'Up to 16 m/s during dust activity'),
            _StatValue('Calm periods', 'Early morning and late evening'),
          ],
          description:
              'Wind on Mars changes with sunlight, topography, and dust movement. In Elysium Planitia, daily heating creates a steady rise in afternoon wind speed before conditions settle again after sunset.',
        );
      case DataScreenType.pressure:
        return const _DataScreenConfig(
          title: 'Data Range Of Pressure',
          subtitle: 'Curiosity-inspired atmospheric pressure trends',
          stats: [
            _StatValue('Current reading', '720 Pa'),
            _StatValue('Seasonal variation', 'Rises and falls with carbon dioxide cycle'),
            _StatValue('Daily shifts', 'Pressure dips before morning sunrise'),
          ],
          description:
              'Pressure on Mars is thin but dynamic. Seasonal freezing and thawing at the poles changes the atmosphere over time, while local heating drives smaller daily pressure swings near the surface.',
        );
      case DataScreenType.temperature:
        return const _DataScreenConfig(
          title: 'Data Range Of Temperature',
          subtitle: 'Surface thermal rhythm between day and night',
          stats: [
            _StatValue('Daytime average', '-19 deg C'),
            _StatValue('Nighttime average', '-83 deg C'),
            _StatValue('Daily variation', 'Large swings because the air is thin'),
          ],
          description:
              'Mars heats quickly in sunlight and cools just as quickly after dark. This large temperature range affects dust activity, hardware design, and how missions plan energy usage across each sol.',
        );
    }
  }
}

/// Configuration data container for a data screen variant
/// 
/// Holds screen title, subtitle, default statistics, and description text.
/// Used to configure wind, pressure, and temperature screens.
class _DataScreenConfig {
  const _DataScreenConfig({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.description,
  });

  final String title;
  final String subtitle;
  final List<_StatValue> stats;
  final String description;
}

/// Simple data class representing a single statistic
/// 
/// Contains a label and its corresponding value for display in stat cards.
class _StatValue {
  const _StatValue(this.label, this.value);

  final String label;
  final String value;
}
