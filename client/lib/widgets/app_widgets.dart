import 'package:flutter/material.dart';
import 'dart:async';

/// Global error handler for GlowStar
/// Catches all Flutter framework errors and displays user-friendly messages
class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._();
  factory AppErrorHandler() => _instance;
  AppErrorHandler._();

  void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      _showErrorToast(details.exception.toString());
    };

    runZonedGuarded(() {
      // App runs here
    }, (Object error, StackTrace stack) {
      debugPrint('Uncaught error: $error');
      _showErrorToast(error.toString());
    });
  }

  static void _showErrorToast(String message) {
    debugPrint('⚠️ Error: $message');
    // In production, integrate with a snackbar or toast provider
  }
}

/// Reusable loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF9C27B0)),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

/// Reusable error widget
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidget({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
                child: const Text('重试', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const EmptyStateWidget({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          ],
        ],
      ),
    );
  }
}
