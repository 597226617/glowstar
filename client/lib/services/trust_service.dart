import 'dart:convert';
import 'package:http/http.dart' as http;

/// Trust Service for GlowStar
/// 
/// Handles user verification, ratings, credit score
class TrustService {
  final String baseUrl;
  final Map<String, String>? headers;

  TrustService({required this.baseUrl, this.headers});

  /// Get user trust score
  Future<Map<String, dynamic>> getTrustScore(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/trust'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load trust score');
  }

  /// Submit verification
  Future<bool> submitVerification({
    required String userId,
    required String type, // student_id, phone, real_name
    required String documentUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/verify'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': type,
        'documentUrl': documentUrl,
      }),
    );
    return response.statusCode == 200;
  }

  /// Rate a user after interaction
  Future<bool> rateUser({
    required String fromUserId,
    required String toUserId,
    required int sincerity, // 1-5
    required int helpfulness, // 1-5
    required int friendliness, // 1-5
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$toUserId/rate'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'fromUserId': fromUserId,
        'sincerity': sincerity,
        'helpfulness': helpfulness,
        'friendliness': friendliness,
        'comment': comment,
      }),
    );
    return response.statusCode == 200;
  }

  /// Get user ratings
  Future<Map<String, dynamic>> getUserRatings(String userId, {int page = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/ratings?page=$page'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load ratings');
  }

  /// Report a user
  Future<bool> reportUser({
    required String reporterId,
    required String reportedId,
    required String reason,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$reportedId/report'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'reporterId': reporterId,
        'reason': reason,
        'description': description,
      }),
    );
    return response.statusCode == 200;
  }
}

/// Trust badges
class TrustBadges {
  static const Map<String, Map<String, dynamic>> allBadges = {
    'verified_phone': {
      'name': '手机号验证',
      'icon': '📱',
      'color': 'blue',
      'description': '已通过手机号验证',
    },
    'verified_student': {
      'name': '学生认证',
      'icon': '🎓',
      'color': 'green',
      'description': '已通过学生证认证',
    },
    'verified_realname': {
      'name': '实名认证',
      'icon': '✅',
      'color': 'purple',
      'description': '已通过实名认证',
    },
    'top_helper': {
      'name': '热心学霸',
      'icon': '🏆',
      'color': 'gold',
      'description': '帮助他人次数排名前 10%',
    },
    'trusted_member': {
      'name': '可信成员',
      'icon': '⭐',
      'color': 'gold',
      'description': '信用分 4.5+ 且无举报记录',
    },
    'night_guardian': {
      'name': '深夜守护者',
      'icon': '🌙',
      'color': 'indigo',
      'description': '深夜活跃且无违规记录',
    },
  };
}
