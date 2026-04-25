package com.hood.server.service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Analytics Service for GlowStar
 * 
 * Tracks user activity, engagement metrics, and app performance
 */
public class AnalyticsService {
    private Map<String, List<UserActivity>> userActivities = new ConcurrentHashMap<>();
    private Map<String, Long> eventCounts = new ConcurrentHashMap<>();
    private Map<String, Double> performanceMetrics = new ConcurrentHashMap<>();

    /**
     * Track user activity
     */
    public void trackActivity(String userId, String eventType, String details) {
        UserActivity activity = new UserActivity(
            userId,
            eventType,
            details,
            System.currentTimeMillis()
        );

        userActivities.computeIfAbsent(userId, k -> new ArrayList<>()).add(activity);
        
        // Update event count
        eventCounts.merge(eventType, 1L, Long::sum);
    }

    /**
     * Get user activity history
     */
    public List<UserActivity> getUserActivity(String userId) {
        return userActivities.getOrDefault(userId, new ArrayList<>());
    }

    /**
     * Get event statistics
     */
    public Map<String, Long> getEventStats() {
        return new HashMap<>(eventCounts);
    }

    /**
     * Record performance metric
     */
    public void recordMetric(String metricName, double value) {
        performanceMetrics.put(metricName, value);
    }

    /**
     * Get performance metrics
     */
    public Map<String, Double> getPerformanceMetrics() {
        return new HashMap<>(performanceMetrics);
    }

    /**
     * Get active users count (last 24 hours)
     */
    public int getActiveUsersCount() {
        long oneDayAgo = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
        
        return (int) userActivities.keySet().stream()
            .filter(userId -> {
                List<UserActivity> activities = userActivities.get(userId);
                return activities != null && !activities.isEmpty() &&
                       activities.get(activities.size() - 1).getTimestamp() > oneDayAgo;
            })
            .count();
    }

    /**
     * Get popular features
     */
    public List<Map.Entry<String, Long>> getPopularFeatures(int limit) {
        return eventCounts.entrySet().stream()
            .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
            .limit(limit)
            .collect(Collectors.toList());
    }

    /**
     * User Activity model
     */
    public static class UserActivity {
        private String userId;
        private String eventType;
        private String details;
        private long timestamp;

        public UserActivity(String userId, String eventType, String details, long timestamp) {
            this.userId = userId;
            this.eventType = eventType;
            this.details = details;
            this.timestamp = timestamp;
        }

        // Getters
        public String getUserId() { return userId; }
        public String getEventType() { return eventType; }
        public String getDetails() { return details; }
        public long getTimestamp() { return timestamp; }
    }
}
