package com.glowstar.server.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.glowstar.server.services.DBInterface;
import spark.Request;
import spark.Response;

import java.sql.*;
import java.util.*;

/**
 * Voice API for GlowStar
 * Handles voice cards, voice messages, voice rooms
 */
public class VoiceApi {
    private final DBInterface db;
    private final Gson gson = new Gson();

    public VoiceApi(DBInterface db) { this.db = db; }

    /** POST /api/voice/card - Upload voice card */
    public Object uploadVoiceCard(Request req, Response res) {
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        String cardId = UUID.randomUUID().toString();
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO voice_cards (id, user_id, audio_url, duration, waveform, created_at) VALUES (?,?,?,?,?,NOW())"
            );
            stmt.setString(1, cardId);
            stmt.setString(2, json.get("userId").getAsString());
            stmt.setString(3, json.get("audioUrl").getAsString());
            stmt.setInt(4, json.has("duration") ? json.get("duration").getAsInt() : 0);
            stmt.setString(5, json.has("waveform") ? json.get("waveform").getAsString() : "[]");
            stmt.executeUpdate();
            res.status(201);
            return gson.toJson(Map.of("id", cardId, "success", true));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** GET /api/voice/card/:userId - Get user's voice card */
    public Object getVoiceCard(Request req, Response res) {
        String userId = req.params("userId");
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT * FROM voice_cards WHERE user_id=? ORDER BY created_at DESC LIMIT 1"
            );
            stmt.setString(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                res.type("application/json");
                return gson.toJson(Map.of(
                    "id", rs.getString("id"),
                    "audioUrl", rs.getString("audio_url"),
                    "duration", rs.getInt("duration"),
                    "waveform", rs.getString("waveform"),
                    "createdAt", rs.getTimestamp("created_at").toString()
                ));
            }
            res.type("application/json");
            return "{}";
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** POST /api/messages/voice - Send voice message */
    public Object sendVoiceMessage(Request req, Response res) {
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        String msgId = UUID.randomUUID().toString();
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO messages (id, conversation_id, sender_id, content, type, media_url, duration, created_at) VALUES (?,?,?,?, 'voice', ?,?, NOW())"
            );
            stmt.setString(1, msgId);
            stmt.setString(2, json.get("conversationId").getAsString());
            stmt.setString(3, json.get("senderId").getAsString());
            stmt.setString(4, ""); // voice message content is empty
            stmt.setString(5, json.get("audioUrl").getAsString());
            stmt.setInt(6, json.has("duration") ? json.get("duration").getAsInt() : 0);
            stmt.executeUpdate();
            res.status(201);
            return gson.toJson(Map.of("id", msgId, "success", true));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** POST /api/voice/rooms - Create voice room */
    public Object createVoiceRoom(Request req, Response res) {
        JsonObject json = gson.fromJson(req.body(), JsonObject.class);
        String roomId = UUID.randomUUID().toString();
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO voice_rooms (id, creator_id, topic, max_participants, is_public, created_at) VALUES (?,?,?,?,?,NOW())"
            );
            stmt.setString(1, roomId);
            stmt.setString(2, json.get("creatorId").getAsString());
            stmt.setString(3, json.has("topic") ? json.get("topic").getAsString() : "");
            stmt.setInt(4, json.has("maxParticipants") ? json.get("maxParticipants").getAsInt() : 8);
            stmt.setBoolean(5, json.has("isPublic") ? json.get("isPublic").getAsBoolean() : true);
            stmt.executeUpdate();
            // Add creator as first participant
            PreparedStatement part = conn.prepareStatement(
                "INSERT INTO room_participants (room_id, user_id, joined_at) VALUES (?,?,NOW())"
            );
            part.setString(1, roomId);
            part.setString(2, json.get("creatorId").getAsString());
            part.executeUpdate();
            res.status(201);
            return gson.toJson(Map.of("id", roomId, "success", true));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }

    /** GET /api/voice/rooms - List active voice rooms */
    public Object listVoiceRooms(Request req, Response res) {
        try (Connection conn = db.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT vr.*, u.nickname, u.avatar, " +
                "(SELECT COUNT(*) FROM room_participants WHERE room_id=vr.id) as participant_count " +
                "FROM voice_rooms vr JOIN users u ON vr.creator_id=u.id " +
                "WHERE vr.is_public=1 AND vr.id NOT IN (SELECT room_id FROM voice_rooms WHERE created_at < DATE_SUB(NOW(), INTERVAL 2 HOUR)) " +
                "ORDER BY vr.created_at DESC LIMIT 20"
            );
            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> rooms = new ArrayList<>();
            while (rs.next()) {
                rooms.add(Map.of(
                    "id", rs.getString("id"),
                    "creatorId", rs.getString("creator_id"),
                    "nickname", rs.getString("nickname"),
                    "avatar", rs.getString("avatar"),
                    "topic", rs.getString("topic"),
                    "participantCount", rs.getInt("participant_count"),
                    "maxParticipants", rs.getInt("max_participants"),
                    "createdAt", rs.getTimestamp("created_at").toString()
                ));
            }
            res.type("application/json");
            return gson.toJson(Map.of("rooms", rooms));
        } catch (Exception e) {
            res.status(500);
            return gson.toJson(Map.of("error", e.getMessage()));
        }
    }
}
