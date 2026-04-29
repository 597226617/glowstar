import 'package:flutter_test/flutter_test.dart';
import 'package:glowstar/model/interest_tag.dart';
import 'package:glowstar/services/matching_service.dart';

void main() {
  group('MatchingService', () {
    test('calculateMatchScore returns 1.0 for identical interests and zero distance', () {
      List<InterestTag> interests = [
        InterestTag(id: 'music_pop', name: 'Pop', category: 'Music', icon: '🎵'),
        InterestTag(id: 'sports_football', name: 'Football', category: 'Sports', icon: '⚽'),
      ];

      double score = MatchingService.calculateMatchScore(
        userInterests: interests,
        otherInterests: interests,
        distanceKm: 0,
        otherActivityScore: 1.0,
      );

      expect(score, 1.0);
    });

    test('calculateMatchScore returns lower score for different interests', () {
      List<InterestTag> userInterests = [
        InterestTag(id: 'music_pop', name: 'Pop', category: 'Music', icon: '🎵'),
      ];

      List<InterestTag> otherInterests = [
        InterestTag(id: 'sports_football', name: 'Football', category: 'Sports', icon: '⚽'),
      ];

      double score = MatchingService.calculateMatchScore(
        userInterests: userInterests,
        otherInterests: otherInterests,
        distanceKm: 0,
        otherActivityScore: 1.0,
      );

      expect(score, lessThan(1.0));
    });

    test('calculateDistanceScore returns 1.0 for zero distance', () {
      expect(MatchingService.calculateDistanceScore(0), 1.0);
    });

    test('calculateDistanceScore returns 0.0 for max distance', () {
      expect(MatchingService.calculateDistanceScore(50.0), 0.0);
    });

    test('calculateDistanceScore returns intermediate value', () {
      double score = MatchingService.calculateDistanceScore(25.0);
      expect(score, 0.5);
    });

    test('getMatchReason returns common interests', () {
      List<InterestTag> interests1 = [
        InterestTag(id: 'music_pop', name: 'Pop', category: 'Music', icon: '🎵'),
        InterestTag(id: 'sports_football', name: 'Football', category: 'Sports', icon: '⚽'),
      ];

      List<InterestTag> interests2 = [
        InterestTag(id: 'music_pop', name: 'Pop', category: 'Music', icon: '🎵'),
        InterestTag(id: 'gaming_fps', name: 'FPS', category: 'Gaming', icon: '🎮'),
      ];

      String reason = MatchingService.getMatchReason(
        userInterests: interests1,
        otherInterests: interests2,
        distanceKm: 0.5,
      );

      expect(reason, contains('Pop'));
      expect(reason, contains('距离很近'));
    });
  });
}
