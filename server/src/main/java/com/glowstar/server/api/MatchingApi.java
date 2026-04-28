package com.glowstar.server.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.glowstar.server.services.DBInterface;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.container.ContainerRequestContext;
import java.sql.*;
import java.util.*;

/**
 * Matching API for GlowStar
 * 
 * Implements the matching algorithm from the design guide:
 * - Interest match: 60%
 * - Distance: 30%
 * - Activity: 10%
 * 
 * Daily recommendations: max 10 users (quality over quantity)
 */
@Path("matching")
public class MatchingApi {
    private static final Logger logger = LoggerFactory.getLogger(MatchingApi.class);
    private final Gson gson = new Gson();

    /**
     * GET /api/matching/daily?userId=xxx&latitude=xxx&longitude=xxx
     * Get daily recommended matches (max 10)
     */
    @GET
    @Path("daily")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getDailyMatches(
            @QueryParam("userId") String userId,
            @QueryParam("latitude") double latitude,
            @QueryParam("longitude") double longitude) {
        
        if (userId == null || userId.isEmpty()) {
            return Response.status(400).entity("{\"error\":\"userId is required\"}").build();
        }
        
        try {
            List<Map<String, Object>> matches = calculateMatches(userId, latitude, longitude, 10);
            return Response.ok(gson.toJson(matches)).build();
        } catch (Exception e) {
            logger.error("Error calculating daily matches for user: {}", userId, e);
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * GET /api/matching/nearby?userId=xxx&latitude=xxx&longitude=xxx&radius=5000
     * Get nearby users with interest info
     */
    @GET
    @Path("nearby")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getNearbyUsers(
            @QueryParam("userId") String userId,
            @QueryParam("latitude") double latitude,
            @QueryParam("longitude") double longitude,
            @QueryParam("radius") @DefaultValue("5000") double radiusMeters) {
        
        if (userId == null || latitude == 0 && longitude == 0) {
            return Response.status(400).entity("{\"error\":\"userId and location are required\"}").build();
        }
        
        try {
            Connection conn = DBInterface.get().getConnection();
            
            // Find nearby users using Haversine-like distance approximation
            // For simplicity, use bounding box first then calculate precise distance
            double latDelta = radiusMeters / 111000.0; // ~111km per degree
            double lonDelta = radiusMeters / (111000.0 * Math.cos(Math.toRadians(latitude)));
            
            String sql = "SELECT u.id, u.nickname, u.avatar, u.bio, u.latitude, u.longitude, u.is_online, " +
                    "u.last_active, " +
                    "GROUP_CONCAT(ui.tag_id || ':' || ui.tag_name || ':' || ui.category, '|') as interests " +
                    "FROM users u " +
                    "LEFT JOIN user_interests ui ON u.id = ui.user_id " +
                    "WHERE u.id != ? " +
                    "AND u.latitude BETWEEN ? AND ? " +
                    "AND u.longitude BETWEEN ? AND ? " +
                    "AND u.is_online = 1 " +
                    "GROUP BY u.id " +
                    "ORDER BY ABS(u.latitude - ?) + ABS(u.longitude - ?) " +
                    "LIMIT 50";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, userId);
            stmt.setDouble(2, latitude - latDelta);
            stmt.setDouble(3, latitude + latDelta);
            stmt.setDouble(4, longitude - lonDelta);
            stmt.setDouble(5, longitude + lonDelta);
            stmt.setDouble(6, latitude);
            stmt.setDouble(7, longitude);
            
            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> nearbyUsers = new ArrayList<>();
            
            while (rs.next()) {
                double userLat = rs.getDouble("latitude");
                double userLon = rs.getDouble("longitude");
                double distance = calculateDistance(latitude, longitude, userLat, userLon);
                
                // Fuzzy the distance for privacy (round to nearest 100m)
                double fuzzyDistance = Math.round(distance / 100.0) * 100.0;
                
                Map<String, Object> user = new LinkedHashMap<>();
                user.put("id", rs.getString("id"));
                user.put("nickname", rs.getString("nickname"));
                user.put("avatar", rs.getString("avatar"));
                user.put("bio", rs.getString("bio"));
                user.put("isOnline", rs.getInt("is_online") == 1);
                user.put("lastActive", rs.getString("last_active"));
                user.put("distance", fuzzyDistance);
                
                // Parse interests
                String interestsStr = rs.getString("interests");
                List<Map<String, String>> interests = parseInterests(interestsStr);
                user.put("interests", interests);
                
                // Determine primary interest color for map
                if (!interests.isEmpty()) {
                    user.put("primaryCategory", interests.get(0).get("category"));
                }
                
                // Calculate match score
                double matchScore = calculateMatchScore(userId, interests, conn);
                user.put("matchScore", Math.round(matchScore * 100.0) / 100.0);
                
                nearbyUsers.add(user);
            }
            
            DBInterface.get().commit();
            
            // Sort by match score descending
            nearbyUsers.sort((a, b) -> Double.compare(
                    (Double) b.get("matchScore"), (Double) a.get("matchScore")));
            
            return Response.ok(gson.toJson(nearbyUsers)).build();
        } catch (Exception e) {
            logger.error("Error getting nearby users", e);
            try { DBInterface.get().rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * GET /api/matching/icebreakers?userId=xxx&targetUserId=xxx
     * Get AI-generated icebreaker suggestions based on shared interests
     */
    @GET
    @Path("icebreakers")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getIcebreakers(
            @QueryParam("userId") String userId,
            @QueryParam("targetUserId") String targetUserId) {
        
        if (userId == null || targetUserId == null) {
            return Response.status(400).entity("{\"error\":\"userId and targetUserId are required\"}").build();
        }
        
        try {
            Connection conn = DBInterface.get().getConnection();
            
            // Find shared interests
            String sql = "SELECT a.tag_id, a.tag_name, a.category " +
                    "FROM user_interests a " +
                    "INNER JOIN user_interests b ON a.tag_id = b.tag_id " +
                    "WHERE a.user_id = ? AND b.user_id = ?";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, userId);
            stmt.setString(2, targetUserId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, String>> sharedInterests = new ArrayList<>();
            while (rs.next()) {
                Map<String, String> interest = new LinkedHashMap<>();
                interest.put("id", rs.getString("tag_id"));
                interest.put("name", rs.getString("tag_name"));
                interest.put("category", rs.getString("category"));
                sharedInterests.add(interest);
            }
            
            // Get target user info
            PreparedStatement userStmt = conn.prepareStatement(
                    "SELECT nickname FROM users WHERE id = ?");
            userStmt.setString(1, targetUserId);
            ResultSet userRs = userStmt.executeQuery();
            String targetNickname = userRs.next() ? userRs.getString("nickname") : "TA";
            
            DBInterface.get().commit();
            
            // Generate icebreaker suggestions
            List<String> icebreakers = generateIcebreakers(targetNickname, sharedInterests);
            
            Map<String, Object> result = new LinkedHashMap<>();
            result.put("sharedInterests", sharedInterests);
            result.put("icebreakers", icebreakers);
            result.put("safetyTip", "💡 第一次见面建议选择公共场所哦～");
            
            return Response.ok(gson.toJson(result)).build();
        } catch (Exception e) {
            logger.error("Error getting icebreakers", e);
            try { DBInterface.get().rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * POST /api/matching/update-location
     * Update user's current location
     */
    @POST
    @Path("update-location")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateLocation(String body) {
        try {
            JsonObject json = gson.fromJson(body, JsonObject.class);
            String userId = json.get("userId").getAsString();
            double latitude = json.get("latitude").getAsDouble();
            double longitude = json.get("longitude").getAsDouble();
            
            Connection conn = DBInterface.get().getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE users SET latitude = ?, longitude = ?, " +
                    "is_online = 1, last_active = datetime('now'), updated_at = datetime('now') " +
                    "WHERE id = ?");
            stmt.setDouble(1, latitude);
            stmt.setDouble(2, longitude);
            stmt.setString(3, userId);
            stmt.executeUpdate();
            DBInterface.get().commit();
            
            return Response.ok("{\"success\":true}").build();
        } catch (Exception e) {
            logger.error("Error updating location", e);
            try { DBInterface.get().rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    // ==================== Private helper methods ====================

    private List<Map<String, Object>> calculateMatches(
            String userId, double latitude, double longitude, int limit) throws SQLException {
        
        Connection conn = DBInterface.get().getConnection();
        
        // Get current user's interests
        Set<String> myInterests = new HashSet<>();
        PreparedStatement myInterestsStmt = conn.prepareStatement(
                "SELECT tag_id FROM user_interests WHERE user_id = ?");
        myInterestsStmt.setString(1, userId);
        ResultSet myRs = myInterestsStmt.executeQuery();
        while (myRs.next()) {
            myInterests.add(myRs.getString("tag_id"));
        }
        
        // Get all candidate users (online, with location, not self)
        String candidateSql = "SELECT u.id, u.nickname, u.avatar, u.bio, u.latitude, u.longitude, " +
                "u.is_online, u.last_active, " +
                "GROUP_CONCAT(ui.tag_id || ':' || ui.tag_name || ':' || ui.category, '|') as interests " +
                "FROM users u " +
                "LEFT JOIN user_interests ui ON u.id = ui.user_id " +
                "WHERE u.id != ? AND u.latitude IS NOT NULL " +
                "GROUP BY u.id";
        
        PreparedStatement stmt = conn.prepareStatement(candidateSql);
        stmt.setString(1, userId);
        ResultSet rs = stmt.executeQuery();
        
        List<Map<String, Object>> candidates = new ArrayList<>();
        
        while (rs.next()) {
            double userLat = rs.getDouble("latitude");
            double userLon = rs.getDouble("longitude");
            String interestsStr = rs.getString("interests");
            List<Map<String, String>> interests = parseInterests(interestsStr);
            
            // Calculate match score
            double interestScore = 0;
            int sharedCount = 0;
            for (Map<String, String> interest : interests) {
                if (myInterests.contains(interest.get("id"))) {
                    sharedCount++;
                }
            }
            if (!myInterests.isEmpty() && !interests.isEmpty()) {
                // Jaccard-like similarity
                interestScore = (double) sharedCount / 
                        (myInterests.size() + interests.size() - sharedCount);
            }
            
            // Distance score (closer = better, max 50km)
            double distance = calculateDistance(latitude, longitude, userLat, userLon);
            double distanceScore = Math.max(0, 1.0 - (distance / 50000.0));
            
            // Activity score (based on last_active)
            double activityScore = calculateActivityScore(rs.getString("last_active"));
            
            // Weighted total: interest 60% + distance 30% + activity 10%
            double totalScore = interestScore * 0.6 + distanceScore * 0.3 + activityScore * 0.1;
            
            // Only include if there's at least some match
            if (sharedCount > 0 || distance < 5000) {
                Map<String, Object> candidate = new LinkedHashMap<>();
                candidate.put("id", rs.getString("id"));
                candidate.put("nickname", rs.getString("nickname"));
                candidate.put("avatar", rs.getString("avatar"));
                candidate.put("bio", rs.getString("bio"));
                candidate.put("isOnline", rs.getInt("is_online") == 1);
                candidate.put("distance", Math.round(distance / 100.0) * 100.0);
                candidate.put("interests", interests);
                candidate.put("sharedInterestCount", sharedCount);
                candidate.put("matchScore", Math.round(totalScore * 100.0) / 100.0);
                
                // Generate match reason
                if (sharedCount > 0) {
                    List<String> sharedNames = new ArrayList<>();
                    for (Map<String, String> interest : interests) {
                        if (myInterests.contains(interest.get("id"))) {
                            sharedNames.add(interest.get("name"));
                        }
                    }
                    candidate.put("matchReason", "你们都喜欢 " + String.join("、", sharedNames) + "！");
                } else if (distance < 1000) {
                    candidate.put("matchReason", "就在你附近～");
                } else {
                    candidate.put("matchReason", "附近的发光星球");
                }
                
                candidates.add(candidate);
            }
        }
        
        DBInterface.get().commit();
        
        // Sort by match score and return top N
        candidates.sort((a, b) -> Double.compare(
                (Double) b.get("matchScore"), (Double) a.get("matchScore")));
        
        if (candidates.size() > limit) {
            candidates = candidates.subList(0, limit);
        }
        
        return candidates;
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        if (lat1 == 0 && lon1 == 0 || lat2 == 0 && lon2 == 0) {
            return Double.MAX_VALUE;
        }
        double earthRadius = 6371000; // meters
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }

    private double calculateActivityScore(String lastActive) {
        if (lastActive == null) return 0.0;
        try {
            // Simple heuristic: more recent = higher score
            // For now, return 0.5 as default (real impl would parse timestamp)
            return 0.5;
        } catch (Exception e) {
            return 0.0;
        }
    }

    private double calculateMatchScore(String userId, List<Map<String, String>> targetInterests, Connection conn) 
            throws SQLException {
        // Get current user's interests
        Set<String> myInterests = new HashSet<>();
        PreparedStatement stmt = conn.prepareStatement(
                "SELECT tag_id FROM user_interests WHERE user_id = ?");
        stmt.setString(1, userId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            myInterests.add(rs.getString("tag_id"));
        }
        
        int shared = 0;
        for (Map<String, String> interest : targetInterests) {
            if (myInterests.contains(interest.get("id"))) {
                shared++;
            }
        }
        
        if (myInterests.isEmpty() || targetInterests.isEmpty()) return 0.0;
        return (double) shared / (myInterests.size() + targetInterests.size() - shared);
    }

    private List<Map<String, String>> parseInterests(String interestsStr) {
        List<Map<String, String>> interests = new ArrayList<>();
        if (interestsStr == null || interestsStr.isEmpty()) return interests;
        
        String[] parts = interestsStr.split("\\|");
        for (String part : parts) {
            String[] fields = part.split(":");
            if (fields.length >= 3) {
                Map<String, String> interest = new LinkedHashMap<>();
                interest.put("id", fields[0]);
                interest.put("name", fields[1]);
                interest.put("category", fields[2]);
                interests.add(interest);
            }
        }
        return interests;
    }

    private List<String> generateIcebreakers(String targetNickname, List<Map<String, String>> sharedInterests) {
        List<String> icebreakers = new ArrayList<>();
        
        if (sharedInterests.isEmpty()) {
            icebreakers.add("嗨 " + targetNickname + "，看到你也在发光星球，很高兴认识你！");
            icebreakers.add("你好呀～看到你就在附近，想认识一下～");
            icebreakers.add("Hi " + targetNickname + "，有什么有趣的兴趣可以分享吗？");
            return icebreakers;
        }
        
        // Generate interest-specific icebreakers
        for (Map<String, String> interest : sharedInterests) {
            String category = interest.get("category");
            String name = interest.get("name");
            
            switch (category != null ? category.toLowerCase() : "") {
                case "music":
                    icebreakers.add(targetNickname + "，你也喜欢" + name + "！最近有听什么好听的吗？");
                    break;
                case "sports":
                    icebreakers.add("嗨～看到你也喜欢" + name + "，最近有在运动吗？");
                    break;
                case "reading":
                    icebreakers.add(targetNickname + "，你也喜欢" + name + "！有什么好书推荐吗？");
                    break;
                case "study":
                    icebreakers.add("看到你也对" + name + "感兴趣，一起学习怎么样？📚");
                    break;
                case "food":
                    icebreakers.add("吃货认证！你也喜欢" + name + "，附近有什么好吃的推荐吗？");
                    break;
                case "travel":
                    icebreakers.add(targetNickname + "，你也爱旅行！最近去过什么好玩的地方吗？");
                    break;
                default:
                    icebreakers.add("看到你也喜欢" + name + "，很高兴遇到同好！✨");
            }
            
            if (icebreakers.size() >= 3) break;
        }
        
        // Always add one generic one
        if (icebreakers.size() < 3) {
            icebreakers.add("你们有 " + sharedInterests.size() + " 个共同兴趣，聊起来一定很有趣！");
        }
        
        return icebreakers;
    }
}
