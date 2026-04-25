import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance Service for GlowStar
/// 
/// Monitors app performance and optimizes resource usage
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final List<PerformanceMetric> _metrics = [];
  Timer? _memoryCheckTimer;

  /// Start performance monitoring
  void startMonitoring() {
    _memoryCheckTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _checkMemoryUsage();
    });
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _memoryCheckTimer?.cancel();
  }

  /// Record a performance metric
  void recordMetric(String name, double value, {String? unit}) {
    _metrics.add(PerformanceMetric(
      name: name,
      value: value,
      unit: unit ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    // Keep only last 1000 metrics
    if (_metrics.length > 1000) {
      _metrics.removeRange(0, _metrics.length - 1000);
    }
  }

  /// Get all metrics
  List<PerformanceMetric> getMetrics() => List.unmodifiable(_metrics);

  /// Get metrics by name
  List<PerformanceMetric> getMetricsByName(String name) {
    return _metrics.where((m) => m.name == name).toList();
  }

  /// Get average value for a metric
  double? getAverageMetric(String name) {
    List<PerformanceMetric> metrics = getMetricsByName(name);
    if (metrics.isEmpty) return null;

    double sum = metrics.fold(0, (sum, m) => sum + m.value);
    return sum / metrics.length;
  }

  /// Check memory usage
  void _checkMemoryUsage() {
    // In real implementation, this would use devtools or native memory APIs
    recordMetric('memory_usage', DateTime.now().millisecondsSinceEpoch.toDouble());
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
  }
}

/// Performance Metric model
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final int timestamp;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
}
