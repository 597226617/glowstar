package com.hood.server.api;

import spark.Request;
import spark.Response;
import spark.Route;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Security API for GlowStar
 * 
 * Handles content moderation, user reporting, and security features
 */
public class SecurityApi {
    private Map<String, List<Report>> reports = new ConcurrentHashMap<>();
    private Map<String, Boolean> blockedUsers = new ConcurrentHashMap<>();
    private List<String> bannedWords = Arrays.asList(
        "暴力", "色情", "诈骗", "赌博", "毒品",
        "violence", "porn", "scam", "gambling", "drugs"
    );

    /**
     * Moderate content
     */
    public Route moderateContent = (Request request, Response response) -> {
        String content = request.queryParams("content");
        boolean hasViolation = false;
        List<String> violations = new ArrayList<>();

        for (String word : bannedWords) {
            if (content.contains(word)) {
                hasViolation = true;
                violations.add("包含不当内容：" + word);
            }
        }

        return Map.of(
            "isSafe", !hasViolation,
            "violations", violations,
            "timestamp", System.currentTimeMillis()
        );
    };

    /**
     * Report user
     */
    public Route reportUser = (Request request, Response response) -> {
        String reporterId = request.queryParams("reporterId");
        String reportedUserId = request.queryParams("reportedUserId");
        String reason = request.queryParams("reason");
        String content = request.queryParams("content");

        Report report = new Report(
            UUID.randomUUID().toString(),
            reporterId,
            reportedUserId,
            reason,
            content,
            System.currentTimeMillis()
        );

        reports.computeIfAbsent(reportedUserId, k -> new ArrayList<>()).add(report);

        response.status(201);
        return Map.of(
            "success", true,
            "reportId", report.getId(),
            "message", "举报已提交，我们会尽快处理"
        );
    };

    /**
     * Block user
     */
    public Route blockUser = (Request request, Response response) -> {
        String blockerId = request.queryParams("blockerId");
        String blockedUserId = request.queryParams("blockedUserId");

        blockedUsers.put(blockerId + ":" + blockedUserId, true);

        return Map.of("success", true, "message", "已屏蔽该用户");
    };

    /**
     * Unblock user
     */
    public Route unblockUser = (Request request, Response response) -> {
        String blockerId = request.queryParams("blockerId");
        String blockedUserId = request.queryParams("blockedUserId");

        blockedUsers.remove(blockerId + ":" + blockedUserId);

        return Map.of("success", true, "message", "已取消屏蔽");
    };

    /**
     * Get user reports
     */
    public Route getUserReports = (Request request, Response response) -> {
        String userId = request.params(":userId");
        List<Report> userReports = reports.getOrDefault(userId, new ArrayList<>());

        return Map.of("userId", userId, "reports", userReports, "count", userReports.size());
    };

    /**
     * Check if user is blocked
     */
    public Route isBlocked = (Request request, Response response) -> {
        String userId1 = request.queryParams("userId1");
        String userId2 = request.queryParams("userId2");

        boolean blocked = blockedUsers.containsKey(userId1 + ":" + userId2) ||
                         blockedUsers.containsKey(userId2 + ":" + userId1);

        return Map.of("blocked", blocked);
    };

    /**
     * Report model
     */
    public static class Report {
        private String id;
        private String reporterId;
        private String reportedUserId;
        private String reason;
        private String content;
        private long timestamp;

        public Report(String id, String reporterId, String reportedUserId, String reason, String content, long timestamp) {
            this.id = id;
            this.reporterId = reporterId;
            this.reportedUserId = reportedUserId;
            this.reason = reason;
            this.content = content;
            this.timestamp = timestamp;
        }

        // Getters
        public String getId() { return id; }
        public String getReporterId() { return reporterId; }
        public String getReportedUserId() { return reportedUserId; }
        public String getReason() { return reason; }
        public String getContent() { return content; }
        public long getTimestamp() { return timestamp; }
    }
}
