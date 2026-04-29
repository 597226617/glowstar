package com.glowstar.server.api;

import com.glowstar.server.model.UserProfile;
import spark.Request;
import spark.Response;
import spark.Route;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Matching API for GlowStar
 * 
 * Handles user matching based on interests, distance, and activity
 */
public class MatchingApi {
    private Map<String, UserProfile> users = new ConcurrentHashMap<>();
    private static final double INTEREST_WEIGHT = 0.6;
    private static final double DISTANCE_WEIGHT = 0.3;
    private static final double ACTIVITY_WEIGHT = 0.1;
    private static final int MAX_DAILY_MATCHES = 10;
    private static final double MAX_DISTANCE_KM = 50.0;

    /**
     * Get match suggestions for user
     */
    public Route getMatchSuggestions = (Request request, Response response) -> {
        String userId = request.params(":userId");
        UserProfile currentUser = users.get(userId);

        if (currentUser == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        double userLat = currentUser.getLatitude();
        double userLng = currentUser.getLongitude();
        List<String> userInterests = currentUser.getInterests();

        List<Map<String, Object>> matches = users.values().stream()
            .filter(u -> !u.getId().equals(userId))
            .map(u -> {
                double distance = calculateDistance(
                    userLat, userLng,
                    u.getLatitude(), u.getLongitude()
                );

                double score = calculateMatchScore(
                    userInterests,
                    u.getInterests(),
                    distance,
                    u.getActivityScore()
                );

                return Map.of(
                    "userId", u.getId(),
                    "displayName", u.getDisplayName(),
                    "avatarUrl", u.getAvatarUrl(),
                    "matchScore", score,
                    "distance", distance,
                    "commonInterests", findCommonInterests(userInterests, u.getInterests())
                );
            })
            .filter(m -> (double) m.get("matchScore") > 0.1)
            .sorted((a, b) -> ((double) b.get("matchScore")).compareTo((double) a.get("matchScore")))
            .limit(MAX_DAILY_MATCHES)
            .collect(Collectors.toList());

        return matches;
    };

    /**
     * Calculate match score between two users
     */
    private double calculateMatchScore(
        List<String> userInterests,
        List<String> otherInterests,
        double distance,
        double activityScore
    ) {
        double interestScore = calculateInterestSimilarity(userInterests, otherInterests);
        double distanceScore = calculateDistanceScore(distance);

        return (interestScore * INTEREST_WEIGHT) +
               (distanceScore * DISTANCE_WEIGHT) +
               (activityScore * ACTIVITY_WEIGHT);
    }

    /**
     * Calculate interest similarity using Jaccard index
     */
    private double calculateInterestSimilarity(List<String> interests1, List<String> interests2) {
        if (interests1 == null || interests2 == null || interests1.isEmpty() || interests2.isEmpty()) {
            return 0.0;
        }

        Set<String> set1 = new HashSet<>(interests1);
        Set<String> set2 = new HashSet<>(interests2);

        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);

        Set<String> union = new HashSet<>(set1);
        union.addAll(set2);

        return union.isEmpty() ? 0.0 : (double) intersection.size() / union.size();
    }

    /**
     * Calculate distance score (inverse distance)
     */
    private double calculateDistanceScore(double distance) {
        if (distance <= 0) return 1.0;
        if (distance >= MAX_DISTANCE_KM) return 0.0;
        return 1.0 - (distance / MAX_DISTANCE_KM);
    }

    /**
     * Calculate distance between two coordinates (Haversine formula)
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth's radius in km

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon/2) * Math.sin(dLon/2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

        return R * c;
    }

    /**
     * Find common interests between two users
     */
    private List<String> findCommonInterests(List<String> interests1, List<String> interests2) {
        if (interests1 == null || interests2 == null) return new ArrayList<>();

        Set<String> set1 = new HashSet<>(interests1);
        Set<String> set2 = new HashSet<>(interests2);
        set1.retainAll(set2);

        return new ArrayList<>(set1);
    }

    /**
     * Get match reason
     */
    public Route getMatchReason = (Request request, Response response) -> {
        String userId = request.params(":userId");
        String otherUserId = request.params(":otherUserId");

        UserProfile user = users.get(userId);
        UserProfile other = users.get(otherUserId);

        if (user == null || other == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        List<String> commonInterests = findCommonInterests(user.getInterests(), other.getInterests());
        double distance = calculateDistance(
            user.getLatitude(), user.getLongitude(),
            other.getLatitude(), other.getLongitude()
        );

        String reason;
        if (commonInterests.isEmpty()) {
            reason = "附近活跃的用户";
        } else {
            String interestsText = commonInterests.stream()
                .limit(3)
                .collect(Collectors.joining("、"));

            if (distance < 1) {
                reason = "你们都喜欢" + interestsText + "，而且距离很近！";
            } else {
                reason = String.format("你们都喜欢%s，距离%.1fkm", interestsText, distance);
            }
        }

        return Map.of("reason", reason, "commonInterests", commonInterests);
    };
}
