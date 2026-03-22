import 'package:flutter/material.dart';

import 'screens/data_screen.dart';
import 'screens/elysium.dart';
import 'screens/gallery.dart';
import 'screens/home.dart';
import 'screens/settings.dart';
import 'screens/splash.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const wind = '/data/wind';
  static const pressure = '/data/pressure';
  static const temperature = '/data/temperature';
  static const elysium = '/elysium';
  static const gallery = '/gallery';
  static const settings = '/settings';
}

class MarsExplorerApp extends StatefulWidget {
  const MarsExplorerApp({super.key});

  @override
  State<MarsExplorerApp> createState() => _MarsExplorerAppState();
}

class _MarsExplorerAppState extends State<MarsExplorerApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aetherion',
            theme: AppTheme.lightTheme(
              accentColor: _appState.accentColor,
              fontSize: _appState.fontSize,
            ),
            darkTheme: AppTheme.darkTheme(
              accentColor: _appState.accentColor,
              fontSize: _appState.fontSize,
            ),
            themeMode: _appState.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.splash:
                  return MaterialPageRoute<void>(
                    builder: (_) => const SplashScreen(),
                    settings: settings,
                  );
                case AppRoutes.home:
                  return MaterialPageRoute<void>(
                    builder: (_) => const HomeScreen(),
                    settings: settings,
                  );
                case AppRoutes.wind:
                  return MaterialPageRoute<void>(
                    builder: (_) => const DataScreen(type: DataScreenType.wind),
                    settings: settings,
                  );
                case AppRoutes.pressure:
                  return MaterialPageRoute<void>(
                    builder: (_) =>
                        const DataScreen(type: DataScreenType.pressure),
                    settings: settings,
                  );
                case AppRoutes.temperature:
                  return MaterialPageRoute<void>(
                    builder: (_) =>
                        const DataScreen(type: DataScreenType.temperature),
                    settings: settings,
                  );
                case AppRoutes.elysium:
                  return MaterialPageRoute<void>(
                    builder: (_) => const ElysiumScreen(),
                    settings: settings,
                  );
                case AppRoutes.gallery:
                  return MaterialPageRoute<void>(
                    builder: (_) => const GalleryScreen(),
                    settings: settings,
                  );
                case AppRoutes.settings:
                  return MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute<void>(
                    builder: (_) => const HomeScreen(),
                    settings: settings,
                  );
              }
            },
          );
        },
      ),
    );
  }
}
