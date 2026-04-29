package com.hood.server.api;

import com.hood.server.model.UserProfile;
import com.hood.server.service.NotificationService;
import spark.Request;
import spark.Response;
import spark.Route;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * User API for GlowStar
 * 
 * Handles user registration, profile management, and matching
 */
public class UserApi {
    private Map<String, UserProfile> users = new ConcurrentHashMap<>();
    private NotificationService notificationService;

    public UserApi(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    /**
     * Register new user
     */
    public Route registerUser = (Request request, Response response) -> {
        String userId = request.params(":id");
        String username = request.queryParams("username");
        String displayName = request.queryParams("displayName");

        UserProfile user = new UserProfile(userId, username, displayName);
        users.put(userId, user);

        response.status(201);
        return Map.of("success", true, "userId", userId);
    };

    /**
     * Get user profile
     */
    public Route getUserProfile = (Request request, Response response) -> {
        String userId = request.params(":id");
        UserProfile user = users.get(userId);

        if (user == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        return user;
    };

    /**
     * Update user profile
     */
    public Route updateUserProfile = (Request request, Response response) -> {
        String userId = request.params(":id");
        UserProfile user = users.get(userId);

        if (user == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        // Update fields from request body
        Map<String, Object> body = request.bodyAsClass(Map.class);
        if (body.containsKey("displayName")) {
            user.setDisplayName((String) body.get("displayName"));
        }
        if (body.containsKey("bio")) {
            user.setBio((String) body.get("bio"));
        }
        if (body.containsKey("interests")) {
            user.setInterests((List<String>) body.get("interests"));
        }
        if (body.containsKey("studySubjects")) {
            user.setStudySubjects((List<String>) body.get("studySubjects"));
        }

        return Map.of("success", true);
    };

    /**
     * Get nearby users
     */
    public Route getNearbyUsers = (Request request, Response response) -> {
        String userId = request.params(":id");
        double latitude = Double.parseDouble(request.queryParams("lat"));
        double longitude = Double.parseDouble(request.queryParams("lng"));
        double maxDistance = Double.parseDouble(request.queryParams("maxDistance", "50.0"));

        UserProfile currentUser = users.get(userId);
        if (currentUser == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        List<UserProfile> nearbyUsers = users.values().stream()
            .filter(u -> !u.getId().equals(userId))
            .filter(u -> u.isNearby(latitude, longitude, maxDistance))
            .toList();

        return nearbyUsers;
    };

    /**
     * Update user location
     */
    public Route updateUserLocation = (Request request, Response response) -> {
        String userId = request.params(":id");
        UserProfile user = users.get(userId);

        if (user == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        double latitude = Double.parseDouble(request.queryParams("lat"));
        double longitude = Double.parseDouble(request.queryParams("lng"));

        user.setLatitude(latitude);
        user.setLongitude(longitude);

        return Map.of("success", true);
    };

    /**
     * Get match suggestions
     */
    public Route getMatchSuggestions = (Request request, Response response) -> {
        String userId = request.params(":id");
        UserProfile currentUser = users.get(userId);

        if (currentUser == null) {
            response.status(404);
            return Map.of("error", "User not found");
        }

        // Simple matching based on interests
        List<UserProfile> matches = users.values().stream()
            .filter(u -> !u.getId().equals(userId))
            .filter(u -> {
                List<String> userInterests = currentUser.getInterests();
                List<String> otherInterests = u.getInterests();
                return userInterests != null && otherInterests != null &&
                       !userInterests.isEmpty() && !otherInterests.isEmpty() &&
                       userInterests.stream().anyMatch(otherInterests::contains);
            })
            .limit(10)
            .toList();

        return matches;
    };
}
