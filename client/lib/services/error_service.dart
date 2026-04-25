import 'dart:convert';
import 'package:flutter/material.dart';

/// Error Service for GlowStar
/// 
/// Handles error logging, reporting, and user-friendly error messages
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final List<ErrorLog> _errorLogs = [];
  final List<ErrorHandler> _handlers = [];

  /// Register error handler
  void registerHandler(ErrorHandler handler) {
    _handlers.add(handler);
  }

  /// Log an error
  void logError(String message, {StackTrace? stackTrace, String? context}) {
    ErrorLog error = ErrorLog(
      message: message,
      stackTrace: stackTrace?.toString() ?? '',
      context: context ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _errorLogs.add(error);

    // Notify handlers
    for (var handler in _handlers) {
      handler.handleError(error);
    }

    // Keep only last 500 errors
    if (_errorLogs.length > 500) {
      _errorLogs.removeRange(0, _errorLogs.length - 500);
    }
  }

  /// Get all error logs
  List<ErrorLog> getErrorLogs() => List.unmodifiable(_errorLogs);

  /// Get recent errors
  List<ErrorLog> getRecentErrors(int count) {
    int startIndex = _errorLogs.length - count;
    if (startIndex < 0) startIndex = 0;
    return _errorLogs.sublist(startIndex);
  }

  /// Clear error logs
  void clearErrorLogs() {
    _errorLogs.clear();
  }

  /// Show user-friendly error dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('出错了'),
        content: Text(_getUserFriendlyMessage(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  /// Convert technical error to user-friendly message
  String _getUserFriendlyMessage(String technicalMessage) {
    if (technicalMessage.contains('Network') || technicalMessage.contains('network')) {
      return '网络连接失败，请检查网络设置后重试';
    }
    if (technicalMessage.contains('Timeout') || technicalMessage.contains('timeout')) {
      return '请求超时，请稍后重试';
    }
    if (technicalMessage.contains('Auth') || technicalMessage.contains('auth')) {
      return '认证失败，请重新登录';
    }
    return '发生了一个错误，请稍后重试';
  }
}

/// Error Log model
class ErrorLog {
  final String message;
  final String stackTrace;
  final String context;
  final int timestamp;

  ErrorLog({
    required this.message,
    required this.stackTrace,
    required this.context,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'stackTrace': stackTrace,
      'context': context,
      'timestamp': timestamp,
    };
  }
}

/// Error Handler interface
abstract class ErrorHandler {
  void handleError(ErrorLog error);
}

/// Console Error Handler
class ConsoleErrorHandler implements ErrorHandler {
  @override
  void handleError(ErrorLog error) {
    debugPrint('Error: ${error.message}');
    if (error.stackTrace.isNotEmpty) {
      debugPrint('Stack: ${error.stackTrace}');
    }
  }
}

/// Remote Error Handler (for error reporting service)
class RemoteErrorHandler implements ErrorHandler {
  final String endpoint;

  RemoteErrorHandler(this.endpoint);

  @override
  void handleError(ErrorLog error) {
    // In real implementation, this would send to error reporting service
    // like Sentry, Crashlytics, etc.
    debugPrint('Sending error to $endpoint: ${error.message}');
  }
}
