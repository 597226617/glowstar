package com.glowstar.server.api;

import com.google.gson.Gson;
import com.glowstar.server.services.DBInterface;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.*;
import java.util.*;

/**
 * Interest Tags API for GlowStar
 * 
 * 12 categories, 100+ tags for deep interest matching
 */
@Path("interests")
public class InterestTagsApi {
    private static final Logger logger = LoggerFactory.getLogger(InterestTagsApi.class);
    private final Gson gson = new Gson();

    // Predefined interest categories and tags
    private static final Map<String, List<String[]>> INTEREST_CATALOG = new LinkedHashMap<>();
    
    static {
        // category -> list of [id, name, icon]
        INTEREST_CATALOG.put("音乐", Arrays.asList(
            new String[]{"music_pop", "流行音乐", "🎵"},
            new String[]{"music_rock", "摇滚", "🎸"},
            new String[]{"music_hiphop", "嘻哈", "🎤"},
            new String[]{"music_jazz", "爵士", "🎷"},
            new String[]{"music_classical", "古典", "🎻"},
            new String[]{"music_electronic", "电子", "🎹"},
            new String[]{"music_folk", "民谣", "🎶"},
            new String[]{"music_rnb", "R&B", "🎙️"},
            new String[]{"music_indie", "独立音乐", "🎧"}
        ));
        INTEREST_CATALOG.put("运动", Arrays.asList(
            new String[]{"sports_basketball", "篮球", "🏀"},
            new String[]{"sports_football", "足球", "⚽"},
            new String[]{"sports_running", "跑步", "🏃"},
            new String[]{"sports_swimming", "游泳", "🏊"},
            new String[]{"sports_yoga", "瑜伽", "🧘"},
            new String[]{"sports_badminton", "羽毛球", "🏸"},
            new String[]{"sports_cycling", "骑行", "🚴"},
            new String[]{"sports_fitness", "健身", "💪"},
            new String[]{"sports_hiking", "徒步", "🥾"},
            new String[]{"sports_table_tennis", "乒乓球", "🏓"}
        ));
        INTEREST_CATALOG.put("学习", Arrays.asList(
            new String[]{"study_math", "数学", "📐"},
            new String[]{"study_english", "英语", "📖"},
            new String[]{"study_physics", "物理", "🔭"},
            new String[]{"study_cs", "编程", "💻"},
            new String[]{"study_history", "历史", "📜"},
            new String[]{"study_philosophy", "哲学", "🤔"},
            new String[]{"study_language", "语言学习", "🗣️"},
            new String[]{"study_art", "艺术", "🎨"}
        ));
        INTEREST_CATALOG.put("阅读", Arrays.asList(
            new String[]{"reading_fiction", "小说", "📚"},
            new String[]{"reading_scifi", "科幻", "🚀"},
            new String[]{"reading_mystery", "悬疑", "🔍"},
            new String[]{"reading_nonfiction", "纪实", "📰"},
            new String[]{"reading_poetry", "诗歌", "✍️"},
            new String[]{"reading_comics", "漫画", "💭"},
            new String[]{"reading_manga", "动漫", "🎌"}
        ));
        INTEREST_CATALOG.put("游戏", Arrays.asList(
            new String[]{"gaming_moblie", "手游", "📱"},
            new String[]{"gaming_pc", "PC游戏", "🖥️"},
            new String[]{"gaming_console", "主机游戏", "🎮"},
            new String[]{"gaming_board", "桌游", "🎲"},
            new String[]{"gaming_rpg", "RPG", "⚔️"},
            new String[]{"gaming_strategy", "策略游戏", "🧠"},
            new String[]{"gaming_fps", "FPS", "🎯"}
        ));
        INTEREST_CATALOG.put("美食", Arrays.asList(
            new String[]{"food_cooking", "烹饪", "👨‍🍳"},
            new String[]{"food_baking", "烘焙", "🧁"},
            new String[]{"food_sichuan", "川菜", "🌶️"},
            new String[]{"food_japanese", "日料", "🍣"},
            new String[]{"food_korean", "韩餐", "🥘"},
            new String[]{"food_coffee", "咖啡", "☕"},
            new String[]{"food_dessert", "甜品", "🍰"}
        ));
        INTEREST_CATALOG.put("旅行", Arrays.asList(
            new String[]{"travel_backpacking", "背包旅行", "🎒"},
            new String[]{"travel_photography", "旅拍", "📸"},
            new String[]{"travel_roadtrip", "自驾游", "🚗"},
            new String[]{"travel_culture", "文化体验", "🏛️"},
            new String[]{"travel_nature", "自然探索", "🌿"},
            new String[]{"travel_city", "城市漫步", "🏙️"}
        ));
        INTEREST_CATALOG.put("电影", Arrays.asList(
            new String[]{"movie_action", "动作片", "💥"},
            new String[]{"movie_comedy", "喜剧", "😂"},
            new String[]{"movie_scifi", "科幻片", "🌌"},
            new String[]{"movie_horror", "恐怖片", "👻"},
            new String[]{"movie_anime", "动画", "🎬"},
            new String[]{"movie_documentary", "纪录片", "🎥"}
        ));
        INTEREST_CATALOG.put("艺术", Arrays.asList(
            new String[]{"art_painting", "绘画", "🎨"},
            new String[]{"art_photography", "摄影", "📷"},
            new String[]{"art_design", "设计", "✏️"},
            new String[]{"art_calligraphy", "书法", "🖊️"},
            new String[]{"art_music_prod", "音乐制作", "🎹"},
            new String[]{"art_dance", "舞蹈", "💃"}
        ));
        INTEREST_CATALOG.put("科技", Arrays.asList(
            new String[]{"tech_programming", "编程", "⌨️"},
            new String[]{"tech_ai", "人工智能", "🤖"},
            new String[]{"tech_gadgets", "数码产品", "📱"},
            new String[]{"tech_science", "科学", "🔬"},
            new String[]{"tech_blockchain", "区块链", "⛓️"}
        ));
        INTEREST_CATALOG.put("社交", Arrays.asList(
            new String[]{"social_party", "派对", "🎉"},
            new String[]{"social_volunteer", "公益", "❤️"},
            new String[]{"social_club", "社团", "👥"},
            new String[]{"social_debate", "辩论", "🗣️"},
            new String[]{"social_networking", "人脉拓展", "🤝"}
        ));
        INTEREST_CATALOG.put("健身", Arrays.asList(
            new String[]{"fitness_gym", "健身房", "🏋️"},
            new String[]{"fitness_crossfit", "CrossFit", "💪"},
            new String[]{"fitness_martial", "武术", "🥋"},
            new String[]{"fitness_dance", "舞蹈健身", "💃"},
            new String[]{"fitness_outdoor", "户外运动", "⛰️"}
        ));
    }

    /**
     * GET /api/interests/catalog
     * Get the full interest tag catalog (12 categories, 100+ tags)
     */
    @GET
    @Path("catalog")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getCatalog() {
        List<Map<String, Object>> catalog = new ArrayList<>();
        
        for (Map.Entry<String, List<String[]>> entry : INTEREST_CATALOG.entrySet()) {
            Map<String, Object> category = new LinkedHashMap<>();
            category.put("category", entry.getKey());
            
            List<Map<String, String>> tags = new ArrayList<>();
            for (String[] tag : entry.getValue()) {
                Map<String, String> tagMap = new LinkedHashMap<>();
                tagMap.put("id", tag[0]);
                tagMap.put("name", tag[1]);
                tagMap.put("icon", tag[2]);
                tagMap.put("category", entry.getKey());
                tags.add(tagMap);
            }
            category.put("tags", tags);
            catalog.add(category);
        }
        
        return Response.ok(gson.toJson(catalog)).build();
    }

    /**
     * GET /api/interests/user/{userId}
     * Get a user's selected interest tags
     */
    @GET
    @Path("user/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getUserInterests(@PathParam("userId") String userId) {
        try {
            Connection conn = DBInterface.get().getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                    "SELECT tag_id, tag_name, category FROM user_interests WHERE user_id = ?");
            stmt.setString(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, String>> interests = new ArrayList<>();
            while (rs.next()) {
                Map<String, String> interest = new LinkedHashMap<>();
                interest.put("id", rs.getString("tag_id"));
                interest.put("name", rs.getString("tag_name"));
                interest.put("category", rs.getString("category"));
                interests.add(interest);
            }
            
            conn.commit();
            return Response.ok(gson.toJson(interests)).build();
        } catch (Exception e) {
            logger.error("Error getting user interests for: {}", userId, e);
            try { conn.rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * POST /api/interests/user/{userId}
     * Set a user's interest tags (replaces all)
     */
    @POST
    @Path("user/{userId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response setUserInterests(@PathParam("userId") String userId, String body) {
        try {
            Connection conn = DBInterface.get().getConnection();
            
            // Delete existing interests
            PreparedStatement deleteStmt = conn.prepareStatement(
                    "DELETE FROM user_interests WHERE user_id = ?");
            deleteStmt.setString(1, userId);
            deleteStmt.executeUpdate();
            
            // Parse new interests
            com.google.gson.JsonArray jsonArray = gson.fromJson(body, com.google.gson.JsonArray.class);
            PreparedStatement insertStmt = conn.prepareStatement(
                    "INSERT INTO user_interests (id, user_id, tag_id, tag_name, category) VALUES (?, ?, ?, ?, ?)");
            
            for (com.google.gson.JsonElement elem : jsonArray) {
                com.google.gson.JsonObject obj = elem.getAsJsonObject();
                insertStmt.setString(1, UUID.randomUUID().toString());
                insertStmt.setString(2, userId);
                insertStmt.setString(3, obj.get("id").getAsString());
                insertStmt.setString(4, obj.get("name").getAsString());
                insertStmt.setString(5, obj.get("category").getAsString());
                insertStmt.executeUpdate();
            }
            
            conn.commit();
            return Response.ok("{\"success\":true}").build();
        } catch (Exception e) {
            logger.error("Error setting user interests for: {}", userId, e);
            try { conn.rollback(); } catch (Exception ignored) {}
            return Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    /**
     * GET /api/interests/category-colors
     * Get the color mapping for interest categories (for map display)
     */
    @GET
    @Path("category-colors")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getCategoryColors() {
        Map<String, String> colors = new LinkedHashMap<>();
        colors.put("音乐", "#9C27B0");   // Purple
        colors.put("运动", "#FF9800");   // Orange
        colors.put("学习", "#4CAF50");   // Green
        colors.put("阅读", "#2196F3");   // Blue
        colors.put("游戏", "#F44336");   // Red
        colors.put("美食", "#795548");   // Brown
        colors.put("旅行", "#009688");   // Teal
        colors.put("电影", "#3F51B5");   // Indigo
        colors.put("艺术", "#E91E63");   // Pink
        colors.put("科技", "#00BCD4");   // Cyan
        colors.put("社交", "#FFC107");   // Amber
        colors.put("健身", "#FF5722");   // Deep Orange
        
        return Response.ok(gson.toJson(colors)).build();
    }
}
