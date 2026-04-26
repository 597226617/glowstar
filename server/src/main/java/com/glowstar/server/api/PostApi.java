package com.glowstar.server.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.glowstar.server.services.DBInterface;
import spark.Request;
import spark.Response;

import java.sql.*;
import java.util.*;

/**
 * Post/Feed API for GlowStar (SQLite)
 */
public class PostApi {
    private final DBInterface db;
    private final Gson gson = new Gson();

    public PostApi(DBInterface db) { this.db = db; }

    /** POST /api/posts - Create a new post */
    public Object createPost(Request req, Response res) {
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        String postId = UUID.randomUUID().toString();
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO posts (id, user_id, content, type, media_url, latitude, longitude, created_at) VALUES (?,?,?,?,?,?,?,datetime('now'))"
            );
            stmt.setString(1, postId);
            stmt.setString(2, json.get("userId").getAsString());
            stmt.setString(3, json.get("content").getAsString());
            stmt.setString(4, json.has("type") ? json.get("type").getAsString() : "text");
            stmt.setString(5, json.has("mediaUrl") ? json.get("mediaUrl").getAsString() : null);
            if (json.has("latitude")) stmt.setDouble(6, json.get("latitude").getAsDouble());
            else stmt.setNull(6, Types.DOUBLE);
            if (json.has("longitude")) stmt.setDouble(7, json.get("longitude").getAsDouble());
            else stmt.setNull(7, Types.DOUBLE);
            stmt.executeUpdate();
            conn.commit();
            res.status(201);
            return gson.toJson(Map.of("id", postId, "success", true));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** GET /api/feed - Get personalized feed */
    public Object getFeed(Request req, Response res) {
        String userId = req.queryParams("userId");
        int page = Optional.ofNullable(req.queryParams("page")).map(Integer::parseInt).orElse(0);
        int limit = Optional.ofNullable(req.queryParams("limit")).map(Integer::parseInt).orElse(20);
        int offset = page * limit;
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT p.*, u.nickname, u.avatar, " +
                "(SELECT COUNT(*) FROM post_likes WHERE post_id=p.id) as like_count, " +
                "(SELECT COUNT(*) FROM post_comments WHERE post_id=p.id) as comment_count, " +
                "(SELECT COUNT(*) FROM post_likes WHERE post_id=p.id AND user_id=?) as is_liked " +
                "FROM posts p " +
                "JOIN users u ON p.user_id=u.id " +
                "WHERE p.user_id IN ( " +
                "  SELECT DISTINCT ui2.user_id FROM user_interests ui1 " +
                "  JOIN user_interests ui2 ON ui1.tag_id=ui2.tag_id AND ui1.user_id != ui2.user_id " +
                "  WHERE ui1.user_id=? " +
                "  UNION SELECT user_id FROM users WHERE id IN (" +
                "    SELECT followed_id FROM follows WHERE follower_id=?" +
                "  )" +
                ") OR p.user_id=? " +
                "ORDER BY p.created_at DESC LIMIT ? OFFSET ?"
            );
            stmt.setString(1, userId);
            stmt.setString(2, userId);
            stmt.setString(3, userId);
            stmt.setString(4, userId);
            stmt.setInt(5, limit);
            stmt.setInt(6, offset);
            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> posts = new ArrayList<>();
            while (rs.next()) {
                posts.add(Map.of(
                    "id", rs.getString("id"),
                    "userId", rs.getString("user_id"),
                    "nickname", rs.getString("nickname"),
                    "avatar", rs.getString("avatar"),
                    "content", rs.getString("content"),
                    "type", rs.getString("type"),
                    "mediaUrl", rs.getString("media_url"),
                    "likeCount", rs.getInt("like_count"),
                    "commentCount", rs.getInt("comment_count"),
                    "isLiked", rs.getInt("is_liked") > 0,
                    "createdAt", rs.getString("created_at")
                ));
            }
            res.type("application/json");
            return gson.toJson(Map.of("posts", posts, "hasMore", posts.size() == limit));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** GET /api/posts/:id - Get single post with comments */
    public Object getPost(Request req, Response res) {
        String postId = req.params("id");
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT p.*, u.nickname, u.avatar, u.bio " +
                "FROM posts p JOIN users u ON p.user_id=u.id WHERE p.id=?"
            );
            stmt.setString(1, postId);
            ResultSet rs = stmt.executeQuery();
            if (!rs.next()) { res.status(404); return "{}"; }
            Map<String, Object> post = new HashMap<>(Map.of(
                "id", rs.getString("id"), "userId", rs.getString("user_id"),
                "nickname", rs.getString("nickname"), "avatar", rs.getString("avatar"),
                "bio", rs.getString("bio"), "content", rs.getString("content"),
                "type", rs.getString("type"), "mediaUrl", rs.getString("media_url"),
                "createdAt", rs.getString("created_at")
            ));
            PreparedStatement cmtStmt = conn.prepareStatement(
                "SELECT pc.*, u.nickname, u.avatar FROM post_comments pc " +
                "JOIN users u ON pc.user_id=u.id WHERE pc.post_id=? ORDER BY pc.created_at ASC LIMIT 50"
            );
            cmtStmt.setString(1, postId);
            ResultSet crs = cmtStmt.executeQuery();
            List<Map<String, Object>> comments = new ArrayList<>();
            while (crs.next()) {
                comments.add(Map.of(
                    "id", crs.getString("id"), "userId", crs.getString("user_id"),
                    "nickname", crs.getString("nickname"), "avatar", crs.getString("avatar"),
                    "content", crs.getString("content"),
                    "createdAt", crs.getString("created_at")
                ));
            }
            post.put("comments", comments);
            res.type("application/json");
            return gson.toJson(post);
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** POST /api/posts/:id/like - Like/unlike a post */
    public Object toggleLike(Request req, Response res) {
        String postId = req.params("id");
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        String userId = json.get("userId").getAsString();
        try (Connection conn = db.getConnection()) {
            PreparedStatement check = conn.prepareStatement(
                "SELECT id FROM post_likes WHERE post_id=? AND user_id=?"
            );
            check.setString(1, postId); check.setString(2, userId);
            if (check.executeQuery().next()) {
                conn.prepareStatement("DELETE FROM post_likes WHERE post_id='" + postId + "' AND user_id='" + userId + "'").executeUpdate();
                conn.commit();
                return gson.toJson(Map.of("liked", false));
            } else {
                PreparedStatement like = conn.prepareStatement(
                    "INSERT INTO post_likes (id, post_id, user_id, created_at) VALUES (?,?,?,datetime('now'))"
                );
                like.setString(1, UUID.randomUUID().toString());
                like.setString(2, postId); like.setString(3, userId);
                like.executeUpdate();
                conn.commit();
                return gson.toJson(Map.of("liked", true));
            }
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** POST /api/posts/:id/comment - Add comment */
    public Object addComment(Request req, Response res) {
        String postId = req.params("id");
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        String commentId = UUID.randomUUID().toString();
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO post_comments (id, post_id, user_id, content, created_at) VALUES (?,?,?,?,datetime('now'))"
            );
            stmt.setString(1, commentId);
            stmt.setString(2, postId);
            stmt.setString(3, json.get("userId").getAsString());
            stmt.setString(4, json.get("content").getAsString());
            stmt.executeUpdate();
            conn.commit();
            res.status(201);
            return gson.toJson(Map.of("id", commentId, "success", true));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }
}
