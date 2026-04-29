package com.glowstar.server.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.glowstar.server.services.DBInterface;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.*;
import java.util.*;

/**
 * Discovery API for GlowStar
 * 
 * Endpoints for exploring users, posts, and content
 */
@Path("discovery")
public class DiscoveryApi {
    private static final Logger logger = LoggerFactory.getLogger(DiscoveryApi.class);
    private final Gson gson = new Gson();

    /**
     * GET /api/discovery/trending-interests
     * Get trending interest tags (most popular among nearby users)
     */
    @GET
    @Path("trending-interests")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getTrendingInterests(
            @QueryParam("latitude") double latitude,
            @QueryParam("longitude") double longitude) {
        try {
            Connection conn = DBInterface.get().getConnection();
            
            String sql = "SELECT tag_name, category, COUNT(*) as count " +
                    "FROM user_interests " +
                    "GROUP BY tag_name, category " +
                    "ORDER BY count DESC " +
                    "LIMIT 20";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> trending = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("tagName", rs.getString("tag_name"));
                item.put("category", rs.getString("category"));
                item.put("count", rs.getInt("count"));
                trending.add(item);
            }
            
            conn.commit();
            return Response.ok(gson.toJson(trending)).build();
        } catch (Exception e) {
            logger.error("Error getting trending interests", e);
            try { conn.rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * GET /api/discovery/online-count
     * Get count of online users (for map display)
     */
    @GET
    @Path("online-count")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getOnlineCount() {
        try {
            Connection conn = DBInterface.get().getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                    "SELECT COUNT(*) as count FROM users WHERE is_online = 1");
            ResultSet rs = stmt.executeQuery();
            
            int count = 0;
            if (rs.next()) {
                count = rs.getInt("count");
            }
            
            conn.commit();
            return Response.ok("{\"onlineCount\":" + count + "}").build();
        } catch (Exception e) {
            logger.error("Error getting online count", e);
            try { conn.rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * POST /api/discovery/user-status
     * Update user online status
     */
    @POST
    @Path("user-status")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateUserStatus(String body) {
        try {
            JsonObject json = gson.fromJson(body, JsonObject.class);
            String userId = json.get("userId").getAsString();
            boolean online = json.get("isOnline").getAsBoolean();
            
            Connection conn = DBInterface.get().getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE users SET is_online = ?, last_active = datetime('now'), " +
                    "updated_at = datetime('now') WHERE id = ?");
            stmt.setInt(1, online ? 1 : 0);
            stmt.setString(2, userId);
            stmt.executeUpdate();
            conn.commit();
            
            return Response.ok("{\"success\":true}").build();
        } catch (Exception e) {
            logger.error("Error updating user status", e);
            try { conn.rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
}
