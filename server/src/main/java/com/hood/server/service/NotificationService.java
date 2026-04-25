package com.hood.server.service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Notification Service for GlowStar
 * 
 * Manages push notifications, in-app notifications, and notification preferences
 */
public class NotificationService {
    private Map<String, List<Notification>> userNotifications = new ConcurrentHashMap<>();
    private Map<String, NotificationPreferences> userPreferences = new ConcurrentHashMap<>();

    /**
     * Notification types
     */
    public enum NotificationType {
        MATCH,
        MESSAGE,
        SYSTEM,
        STUDY_GROUP,
        REMINDER
    }

    /**
     * Send notification to user
     */
    public void sendNotification(String userId, NotificationType type, String title, String content) {
        Notification notification = new Notification(
            UUID.randomUUID().toString(),
            type,
            title,
            content,
            System.currentTimeMillis(),
            false
        );

        userNotifications.computeIfAbsent(userId, k -> new ArrayList<>()).add(notification);
    }

    /**
     * Get user notifications
     */
    public List<Notification> getUserNotifications(String userId) {
        return userNotifications.getOrDefault(userId, new ArrayList<>());
    }

    /**
     * Mark notification as read
     */
    public void markAsRead(String notificationId) {
        for (List<Notification> notifications : userNotifications.values()) {
            for (Notification notification : notifications) {
                if (notification.getId().equals(notificationId)) {
                    notification.setRead(true);
                    return;
                }
            }
        }
    }

    /**
     * Mark all notifications as read for user
     */
    public void markAllAsRead(String userId) {
        List<Notification> notifications = userNotifications.get(userId);
        if (notifications != null) {
            for (Notification notification : notifications) {
                notification.setRead(true);
            }
        }
    }

    /**
     * Get unread notification count
     */
    public int getUnreadCount(String userId) {
        List<Notification> notifications = userNotifications.get(userId);
        if (notifications == null) return 0;

        return (int) notifications.stream()
            .filter(n -> !n.isRead())
            .count();
    }

    /**
     * Update notification preferences
     */
    public void updatePreferences(String userId, NotificationPreferences preferences) {
        userPreferences.put(userId, preferences);
    }

    /**
     * Get notification preferences
     */
    public NotificationPreferences getPreferences(String userId) {
        return userPreferences.getOrDefault(userId, new NotificationPreferences());
    }

    /**
     * Delete notification
     */
    public void deleteNotification(String userId, String notificationId) {
        List<Notification> notifications = userNotifications.get(userId);
        if (notifications != null) {
            notifications.removeIf(n -> n.getId().equals(notificationId));
        }
    }

    /**
     * Notification model
     */
    public static class Notification {
        private String id;
        private NotificationType type;
        private String title;
        private String content;
        private long timestamp;
        private boolean isRead;

        public Notification(String id, NotificationType type, String title, String content, long timestamp, boolean isRead) {
            this.id = id;
            this.type = type;
            this.title = title;
            this.content = content;
            this.timestamp = timestamp;
            this.isRead = isRead;
        }

        // Getters and Setters
        public String getId() { return id; }
        public NotificationType getType() { return type; }
        public String getTitle() { return title; }
        public String getContent() { return content; }
        public long getTimestamp() { return timestamp; }
        public boolean isRead() { return isRead; }
        public void setRead(boolean read) { isRead = read; }
    }

    /**
     * Notification preferences model
     */
    public static class NotificationPreferences {
        private boolean matchNotifications = true;
        private boolean messageNotifications = true;
        private boolean systemNotifications = true;
        private boolean studyGroupNotifications = true;
        private boolean soundEnabled = true;
        private boolean vibrationEnabled = true;

        // Getters and Setters
        public boolean isMatchNotifications() { return matchNotifications; }
        public void setMatchNotifications(boolean matchNotifications) { this.matchNotifications = matchNotifications; }

        public boolean isMessageNotifications() { return messageNotifications; }
        public void setMessageNotifications(boolean messageNotifications) { this.messageNotifications = messageNotifications; }

        public boolean isSystemNotifications() { return systemNotifications; }
        public void setSystemNotifications(boolean systemNotifications) { this.systemNotifications = systemNotifications; }

        public boolean isStudyGroupNotifications() { return studyGroupNotifications; }
        public void setStudyGroupNotifications(boolean studyGroupNotifications) { this.studyGroupNotifications = studyGroupNotifications; }

        public boolean isSoundEnabled() { return soundEnabled; }
        public void setSoundEnabled(boolean soundEnabled) { this.soundEnabled = soundEnabled; }

        public boolean isVibrationEnabled() { return vibrationEnabled; }
        public void setVibrationEnabled(boolean vibrationEnabled) { this.vibrationEnabled = vibrationEnabled; }
    }
}
