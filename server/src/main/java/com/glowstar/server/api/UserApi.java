package com.glowstar.server.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.glowstar.server.services.DBInterface;
import spark.Request;
import spark.Response;

import java.sql.*;
import java.util.*;

/**
 * User API for GlowStar (SQLite)
 */
public class UserApi {
    private final DBInterface db;
    private final Gson gson = new Gson();

    public UserApi(DBInterface db) {
        this.db = db;
    }

    /** GET /api/users/:id - Get user profile */
    public Object getProfile(Request req, Response res) {
        String userId = req.params("id");
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT u.*, COUNT(DISTINCT ui.id) as interest_count, " +
                "COUNT(DISTINCT gm.group_id) as group_count " +
                "FROM users u " +
                "LEFT JOIN user_interests ui ON u.id = ui.user_id " +
                "LEFT JOIN group_members gm ON u.id = gm.user_id " +
                "WHERE u.id = ? GROUP BY u.id"
            );
            stmt.setString(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                res.type("application/json");
                return gson.toJson(Map.of(
                    "id", rs.getString("id"),
                    "nickname", rs.getString("nickname"),
                    "bio", rs.getString("bio"),
                    "avatar", rs.getString("avatar"),
                    "interestCount", rs.getInt("interest_count"),
                    "groupCount", rs.getInt("group_count"),
                    "createdAt", rs.getString("created_at")
                ));
            }
            res.status(404);
            return gson.toJson(Map.of("error", "User not found"));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** PUT /api/users/:id - Update user profile */
    public Object updateProfile(Request req, Response res) {
        String userId = req.params("id");
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        try (Connection conn = db.getConnection()) {
            conn.setAutoCommit(false);
            if (json.has("nickname") || json.has("bio") || json.has("avatar")) {
                PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE users SET nickname=?, bio=?, avatar=?, updated_at=datetime('now') WHERE id=?"
                );
                stmt.setString(1, json.has("nickname") ? json.get("nickname").getAsString() : "");
                stmt.setString(2, json.has("bio") ? json.get("bio").getAsString() : "");
                stmt.setString(3, json.has("avatar") ? json.get("avatar").getAsString() : "");
                stmt.setString(4, userId);
                stmt.executeUpdate();
            }
            if (json.has("interests")) {
                conn.prepareStatement("DELETE FROM user_interests WHERE user_id='" + userId + "'").executeUpdate();
                for (var interest : json.get("interests").getAsJsonArray()) {
                    JsonObject obj = interest.getAsJsonObject();
                    PreparedStatement stmt = conn.prepareStatement(
                        "INSERT INTO user_interests (id, user_id, tag_id, tag_name, category) VALUES (?,?,?,?,?)"
                    );
                    stmt.setString(1, UUID.randomUUID().toString());
                    stmt.setString(2, userId);
                    stmt.setString(3, obj.get("id").getAsString());
                    stmt.setString(4, obj.get("name").getAsString());
                    stmt.setString(5, obj.get("category").getAsString());
                    stmt.executeUpdate();
                }
            }
            conn.commit();
            res.type("application/json");
            return gson.toJson(Map.of("success", true));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** GET /api/users/:id/stats - Get user stats */
    public Object getStats(Request req, Response res) {
        String userId = req.params("id");
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT " +
                "(SELECT COUNT(*) FROM posts WHERE user_id=?) as post_count, " +
                "(SELECT COUNT(*) FROM follows WHERE follower_id=?) as match_count, " +
                "(SELECT COUNT(DISTINCT gm.group_id) FROM group_members gm JOIN study_groups sg ON gm.group_id=sg.id WHERE gm.user_id=?) as group_count, " +
                "(SELECT COALESCE(SUM(helpful_count),0) FROM answers WHERE user_id=?) as help_count, " +
                "(SELECT level FROM user_levels WHERE user_id=?) as level, " +
                "(SELECT xp FROM user_levels WHERE user_id=?) as xp"
            );
            for (int i = 1; i <= 6; i++) stmt.setString(i, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                res.type("application/json");
                return gson.toJson(Map.of(
                    "postCount", rs.getInt("post_count"),
                    "matchCount", rs.getInt("match_count"),
                    "groupCount", rs.getInt("group_count"),
                    "helpCount", rs.getInt("help_count"),
                    "level", rs.getInt("level"),
                    "xp", rs.getInt("xp")
                ));
            }
            res.status(404);
            return "{}";
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }
}
