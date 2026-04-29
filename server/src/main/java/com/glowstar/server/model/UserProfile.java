package com.hood.server.model;

import java.util.List;

/**
 * User Profile Model for GlowStar
 * 
 * Extends basic user data with interests, preferences, and matching info
 */
public class UserProfile {
    private String id;
    private String username;
    private String displayName;
    private String avatarUrl;
    private double latitude;
    private double longitude;
    private List<String> interests;
    private List<String> studySubjects;
    private double activityScore;
    private boolean isOnline;
    private long lastSeen;
    private String bio;
    private int age;
    private String location;

    public UserProfile() {
    }

    public UserProfile(String id, String username, String displayName) {
        this.id = id;
        this.username = username;
        this.displayName = displayName;
        this.activityScore = 0.5;
        this.isOnline = false;
        this.lastSeen = System.currentTimeMillis();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public List<String> getInterests() { return interests; }
    public void setInterests(List<String> interests) { this.interests = interests; }

    public List<String> getStudySubjects() { return studySubjects; }
    public void setStudySubjects(List<String> studySubjects) { this.studySubjects = studySubjects; }

    public double getActivityScore() { return activityScore; }
    public void setActivityScore(double activityScore) { this.activityScore = activityScore; }

    public boolean isOnline() { return isOnline; }
    public void setOnline(boolean online) { isOnline = online; }

    public long getLastSeen() { return lastSeen; }
    public void setLastSeen(long lastSeen) { this.lastSeen = lastSeen; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    /**
     * Update activity score based on recent actions
     */
    public void updateActivityScore() {
        long now = System.currentTimeMillis();
        long hoursSinceLastSeen = (now - lastSeen) / (1000 * 60 * 60);
        
        // Decay score over time
        double decay = Math.max(0.1, 1.0 - (hoursSinceLastSeen * 0.05));
        this.activityScore = Math.min(1.0, this.activityScore * decay + 0.1);
        this.lastSeen = now;
    }

    /**
     * Check if user is nearby (within distance km)
     */
    public boolean isNearby(double otherLat, double otherLng, double maxDistanceKm) {
        double distance = calculateDistance(latitude, longitude, otherLat, otherLng);
        return distance <= maxDistanceKm;
    }

    /**
     * Haversine distance calculation
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
}
