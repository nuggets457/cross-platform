import 'package:flutter/material.dart';

import '../app.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  void _open(BuildContext context, String route) {
    final activeRoute = ModalRoute.of(context)?.settings.name;
    if (route == activeRoute) {
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  int _getSelectedIndex() {
    switch (currentRoute) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.gallery:
        return 1;
      case AppRoutes.settings:
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.image_outlined),
          selectedIcon: Icon(Icons.image),
          label: 'Gallery',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      selectedIndex: _getSelectedIndex(),
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            _open(context, AppRoutes.home);
            break;
          case 1:
            _open(context, AppRoutes.gallery);
            break;
          case 2:
            _open(context, AppRoutes.settings);
            break;
        }
      },
      surfaceTintColor: Colors.transparent,
    );
  }
}
