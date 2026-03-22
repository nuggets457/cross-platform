import 'package:flutter/material.dart';

enum AppAccentColor { blue, purple, red, teal }

enum AppFontSize { small, medium, large }

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppAccentColor _accentColor = AppAccentColor.blue;
  AppFontSize _fontSize = AppFontSize.medium;
  int _galleryGridCount = 2;
  bool _notificationsEnabled = true;
  bool _dailySpaceImageNotification = true;
  bool _breakingSpaceNewsAlerts = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  String _uiStyle = 'soft';
  bool _animationsEnabled = true;
  bool _backgroundEffectsEnabled = true;
  final Set<String> _favoritePhotoUrls = <String>{};

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppAccentColor get accentColor => _accentColor;
  AppFontSize get fontSize => _fontSize;
  int get galleryGridCount => _galleryGridCount;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailySpaceImageNotification => _dailySpaceImageNotification;
  bool get breakingSpaceNewsAlerts => _breakingSpaceNewsAlerts;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  String get uiStyle => _uiStyle;
  bool get animationsEnabled => _animationsEnabled;
  bool get backgroundEffectsEnabled => _backgroundEffectsEnabled;
  Set<String> get favoritePhotoUrls =>
      Set<String>.unmodifiable(_favoritePhotoUrls);

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setAccentColor(AppAccentColor color) {
    _accentColor = color;
    notifyListeners();
  }

  void setFontSize(AppFontSize size) {
    _fontSize = size;
    notifyListeners();
  }

  void setGalleryGridCount(int count) {
    if (count < 2) {
      _galleryGridCount = 2;
    } else if (count > 4) {
      _galleryGridCount = 4;
    } else {
      _galleryGridCount = count;
    }
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void setDailySpaceImageNotification(bool enabled) {
    _dailySpaceImageNotification = enabled;
    notifyListeners();
  }

  void setBreakingSpaceNewsAlerts(bool enabled) {
    _breakingSpaceNewsAlerts = enabled;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
    notifyListeners();
  }

  void setUIStyle(String style) {
    if (style == 'soft' || style == 'sharp') {
      _uiStyle = style;
      notifyListeners();
    }
  }

  void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
    notifyListeners();
  }

  void setBackgroundEffectsEnabled(bool enabled) {
    _backgroundEffectsEnabled = enabled;
    notifyListeners();
  }

  bool isFavorite(String url) => _favoritePhotoUrls.contains(url);

  void toggleFavorite(String url) {
    if (_favoritePhotoUrls.contains(url)) {
      _favoritePhotoUrls.remove(url);
    } else {
      _favoritePhotoUrls.add(url);
    }
    notifyListeners();
  }

  void clearFavorites() {
    _favoritePhotoUrls.clear();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!.notifier!;
  }
}
