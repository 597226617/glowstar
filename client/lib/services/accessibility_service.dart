import 'package:flutter/material.dart';

/// Accessibility Service for GlowStar
/// 
/// Supports screen readers, font scaling, and high contrast mode
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _screenReaderEnabled = false;

  /// Get font scale
  double getFontScale() => _fontScale;

  /// Set font scale
  void setFontScale(double scale) {
    _fontScale = scale.clamp(0.8, 2.0);
  }

  /// Increase font size
  void increaseFontSize() {
    _fontScale = (_fontScale + 0.2).clamp(0.8, 2.0);
  }

  /// Decrease font size
  void decreaseFontSize() {
    _fontScale = (_fontScale - 0.2).clamp(0.8, 2.0);
  }

  /// Check if high contrast is enabled
  bool isHighContrast() => _highContrast;

  /// Toggle high contrast
  void toggleHighContrast() {
    _highContrast = !_highContrast;
  }

  /// Check if reduce motion is enabled
  bool isReduceMotion() => _reduceMotion;

  /// Toggle reduce motion
  void toggleReduceMotion() {
    _reduceMotion = !_reduceMotion;
  }

  /// Check if screen reader is enabled
  bool isScreenReaderEnabled() => _screenReaderEnabled;

  /// Toggle screen reader
  void toggleScreenReader() {
    _screenReaderEnabled = !_screenReaderEnabled;
  }

  /// Get theme based on accessibility settings
  ThemeData getTheme() {
    if (_highContrast) {
      return ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.yellow,
        ),
      );
    }
    
    return ThemeData.light();
  }

  /// Get animation duration based on reduce motion setting
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_reduceMotion) {
      return Duration.zero;
    }
    return defaultDuration;
  }
}
