import 'package:hood/model/interest_tag.dart';
import 'dart:math';

/// Matching Service for GlowStar
/// 
/// Implements interest-based matching algorithm
/// Formula: Interest 60% + Distance 30% + Activity 10%
class MatchingService {
  static const double INTEREST_WEIGHT = 0.6;
  static const double DISTANCE_WEIGHT = 0.3;
  static const double ACTIVITY_WEIGHT = 0.1;
  static const int MAX_DAILY_MATCHES = 10;
  static const double MAX_DISTANCE_KM = 50.0;

  /// Calculate match score between two users
  /// Returns score from 0.0 to 1.0
  static double calculateMatchScore({
    required List<InterestTag> userInterests,
    required List<InterestTag> otherInterests,
    required double distanceKm,
    required double otherActivityScore,
  }) {
    // Interest similarity (0-1)
    double interestScore = calculateInterestSimilarity(userInterests, otherInterests);
    
    // Distance score (0-1, closer is better)
    double distanceScore = calculateDistanceScore(distanceKm);
    
    // Activity score (0-1)
    double activityScore = otherActivityScore;
    
    // Weighted total
    double totalScore = (interestScore * INTEREST_WEIGHT) +
                        (distanceScore * DISTANCE_WEIGHT) +
                        (activityScore * ACTIVITY_WEIGHT);
    
    return totalScore.clamp(0.0, 1.0);
  }

  /// Calculate interest similarity using Jaccard index
  static double calculateInterestSimilarity(
    List<InterestTag> interests1,
    List<InterestTag> interests2,
  ) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.0;
    
    Set<String> set1 = interests1.map((t) => t.id).toSet();
    Set<String> set2 = interests2.map((t) => t.id).toSet();
    
    // Intersection
    Set<String> intersection = set1.intersection(set2);
    
    // Union
    Set<String> union = set1.union(set2);
    
    if (union.isEmpty) return 0.0;
    
    return intersection.length / union.length;
  }

  /// Calculate distance score (inverse distance)
  static double calculateDistanceScore(double distanceKm) {
    if (distanceKm <= 0) return 1.0;
    if (distanceKm >= MAX_DISTANCE_KM) return 0.0;
    
    // Inverse distance: closer = higher score
    return 1.0 - (distanceKm / MAX_DISTANCE_KM);
  }

  /// Get daily matches for a user
  static List<Map<String, dynamic>> getDailyMatches({
    required List<InterestTag> userInterests,
    required double userLat,
    required double userLng,
    required List<Map<String, dynamic>> potentialMatches,
  }) {
    List<Map<String, dynamic>> scoredMatches = [];
    
    for (var match in potentialMatches) {
      double distance = calculateDistance(
        userLat, userLng,
        match['latitude'], match['longitude'],
      );
      
      double score = calculateMatchScore(
        userInterests: userInterests,
        otherInterests: (match['interests'] as List<dynamic>)
            .map((i) => InterestTag.fromJson(i as Map<String, dynamic>))
            .toList(),
        distanceKm: distance,
        otherActivityScore: match['activityScore'] ?? 0.5,
      );
      
      scoredMatches.add({
        ...match,
        'matchScore': score,
        'distance': distance,
      });
    }
    
    // Sort by score descending
    scoredMatches.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));
    
    // Return top matches
    return scoredMatches.take(MAX_DAILY_MATCHES).toList();
  }

  /// Calculate distance between two coordinates (Haversine formula)
  static double calculateDistance(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const double earthRadius = 6371.0; // km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
               sin(dLng / 2) * sin(dLng / 2);
    
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Get match reason (why these users are matched)
  static String getMatchReason({
    required List<InterestTag> userInterests,
    required List<InterestTag> otherInterests,
    required double distanceKm,
  }) {
    Set<String> set1 = userInterests.map((t) => t.id).toSet();
    Set<String> set2 = otherInterests.map((t) => t.id).toSet();
    Set<String> common = set1.intersection(set2);
    
    if (common.isEmpty) {
      return '附近活跃的用户';
    }
    
    List<String> commonNames = common
        .map((id) => otherInterests.firstWhere((t) => t.id == id).name)
        .toList();
    
    String interestsText = commonNames.take(3).join('、');
    
    if (distanceKm < 1) {
      return '你们都喜欢$interestsText，而且距离很近！';
    } else {
      return '你们都喜欢$interestsText，距离${distanceKm.toStringAsFixed(1)}km';
    }
  }
}
