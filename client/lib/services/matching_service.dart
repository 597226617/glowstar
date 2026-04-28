import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'model/interest_tag.dart';

/// Matching Service for GlowStar
/// 
/// Communicates with the matching API to get:
/// - Daily recommended matches (max 10)
/// - Nearby users with interest-based map markers
/// - Icebreaker suggestions for conversations
class MatchingService {
  final String baseUrl;
  final http.Client _client;

  MatchingService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Get daily recommended matches (max 10, quality over quantity)
  Future<List<MatchResult>> getDailyMatches({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
        '$baseUrl/api/matching/daily?userId=$userId&latitude=$latitude&longitude=$longitude',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MatchResult.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting daily matches: $e');
      return [];
    }
  }

  /// Get nearby users for map display
  Future<List<NearbyUser>> getNearbyUsers({
    required String userId,
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
        '$baseUrl/api/matching/nearby?userId=$userId'
        '&latitude=$latitude&longitude=$longitude&radius=$radiusMeters',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NearbyUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting nearby users: $e');
      return [];
    }
  }

  /// Get icebreaker suggestions for a match
  Future<IcebreakerResult> getIcebreakers({
    required String userId,
    required String targetUserId,
  }) async {
    try {
      final response = await _client.get(Uri.parse(
        '$baseUrl/api/matching/icebreakers?userId=$userId&targetUserId=$targetUserId',
      ));

      if (response.statusCode == 200) {
        return IcebreakerResult.fromJson(json.decode(response.body));
      }
      return IcebreakerResult.empty();
    } catch (e) {
      print('Error getting icebreakers: $e');
      return IcebreakerResult.empty();
    }
  }

  /// Update user's current location
  Future<bool> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/matching/update-location'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Match result from the matching algorithm
class MatchResult {
  final String id;
  final String nickname;
  final String? avatar;
  final String? bio;
  final bool isOnline;
  final double distance; // fuzzy distance in meters
  final List<InterestTag> interests;
  final int sharedInterestCount;
  final double matchScore;
  final String matchReason;

  const MatchResult({
    required this.id,
    required this.nickname,
    this.avatar,
    this.bio,
    this.isOnline = false,
    this.distance = 0,
    this.interests = const [],
    this.sharedInterestCount = 0,
    this.matchScore = 0,
    this.matchReason = '',
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      id: json['id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((i) => InterestTag.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      sharedInterestCount: json['sharedInterestCount'] as int? ?? 0,
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0,
      matchReason: json['matchReason'] as String? ?? '',
    );
  }

  String get distanceText {
    if (distance < 1000) return '${distance.round()}m';
    return '${(distance / 1000).toStringAsFixed(1)}km';
  }
}

/// Nearby user for map display
class NearbyUser {
  final String id;
  final String nickname;
  final String? avatar;
  final String? bio;
  final bool isOnline;
  final double distance;
  final List<InterestTag> interests;
  final String? primaryCategory;
  final double matchScore;
  final String? lastActive;

  const NearbyUser({
    required this.id,
    required this.nickname,
    this.avatar,
    this.bio,
    this.isOnline = false,
    this.distance = 0,
    this.interests = const [],
    this.primaryCategory,
    this.matchScore = 0,
    this.lastActive,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      id: json['id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((i) => InterestTag.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      primaryCategory: json['primaryCategory'] as String?,
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0,
      lastActive: json['lastActive'] as String?,
    );
  }

  /// Get the color for this user's primary interest (for map marker)
  int get markerColor {
    if (primaryCategory != null) {
      return InterestColors.getColor(primaryCategory!);
    }
    if (interests.isNotEmpty) {
      return InterestColors.getColorForTag(interests.first);
    }
    return 0xFF9E9E9E;
  }

  String get distanceText {
    if (distance < 1000) return '${distance.round()}m';
    return '${(distance / 1000).toStringAsFixed(1)}km';
  }
}

/// Icebreaker suggestions result
class IcebreakerResult {
  final List<InterestTag> sharedInterests;
  final List<String> icebreakers;
  final String safetyTip;

  const IcebreakerResult({
    this.sharedInterests = const [],
    this.icebreakers = const [],
    this.safetyTip = '',
  });

  factory IcebreakerResult.fromJson(Map<String, dynamic> json) {
    return IcebreakerResult(
      sharedInterests: (json['sharedInterests'] as List<dynamic>?)
              ?.map((i) => InterestTag.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      icebreakers: (json['icebreakers'] as List<dynamic>?)
              ?.map((i) => i as String)
              .toList() ??
          [],
      safetyTip: json['safetyTip'] as String? ?? '',
    );
  }

  factory IcebreakerResult.empty() => const IcebreakerResult();
}
