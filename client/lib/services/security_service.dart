import 'package:flutter/material.dart';

/// Security Service for GlowStar
/// 
/// Implements minor protection, content moderation, and reporting
class SecurityService {
  static const int MINOR_AGE_LIMIT = 18;
  static const List<String> BANNED_WORDS = [
    '暴力', '色情', '诈骗', '赌博', '毒品',
    '暴力', '色情', '诈骗', '赌博', '毒品',
  ];

  /// Check if user is a minor
  static bool isMinor(int age) {
    return age < MINOR_AGE_LIMIT;
  }

  /// Moderate content (text, images, etc.)
  static Map<String, dynamic> moderateContent(String content) {
    bool hasViolation = false;
    List<String> violations = [];

    for (String word in BANNED_WORDS) {
      if (content.contains(word)) {
        hasViolation = true;
        violations.add('包含不当内容：$word');
      }
    }

    return {
      'isSafe': !hasViolation,
      'violations': violations,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Generate safety tips for minors
  static List<String> getMinorSafetyTips() {
    return [
      '不要透露个人信息（姓名、学校、地址等）',
      '不要与陌生人见面',
      '遇到不适内容立即举报',
      '告诉家长你的网络活动',
      '不要点击不明链接',
    ];
  }

  /// Report user content
  static Future<Map<String, dynamic>> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    required String content,
  }) async {
    // In real implementation, this would send to server
    return {
      'success': true,
      'reportId': 'RPT_${DateTime.now().millisecondsSinceEpoch}',
      'message': '举报已提交，我们会尽快处理',
    };
  }

  /// Block user
  static Future<Map<String, dynamic>> blockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    // In real implementation, this would update server
    return {
      'success': true,
      'message': '已屏蔽该用户',
    };
  }

  /// Parental control settings
  static Map<String, dynamic> getParentalControls() {
    return {
      'timeLimit': 120, // minutes per day
      'contentFilter': true,
      'contactApproval': true,
      'locationSharing': false,
    };
  }
}
