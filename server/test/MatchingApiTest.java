package com.glowstar.server.api;

import com.glowstar.server.model.UserProfile;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import java.util.Arrays;
import java.util.List;

/**
 * Tests for MatchingApi
 */
public class MatchingApiTest {
    private MatchingApi matchingApi;

    @BeforeEach
    public void setUp() {
        matchingApi = new MatchingApi();
    }

    @Test
    public void testCalculateDistance() {
        // Test distance calculation between Beijing and Shanghai
        double beijingLat = 39.9042;
        double beijingLng = 116.4074;
        double shanghaiLat = 31.2304;
        double shanghaiLng = 121.4737;

        double distance = matchingApi.calculateDistance(
            beijingLat, beijingLng,
            shanghaiLat, shanghaiLng
        );

        // Expected distance is approximately 1068 km
        assertTrue(distance > 1000 && distance < 1200, "Distance should be approximately 1068 km");
    }

    @Test
    public void testCalculateInterestSimilarity() {
        List<String> interests1 = Arrays.asList("music", "sports", "gaming");
        List<String> interests2 = Arrays.asList("music", "reading", "travel");

        double similarity = matchingApi.calculateInterestSimilarity(interests1, interests2);

        // Jaccard similarity: 1 common / 5 unique = 0.2
        assertEquals(0.2, similarity, 0.01, "Similarity should be 0.2");
    }

    @Test
    public void testCalculateDistanceScore() {
        // Zero distance should return 1.0
        assertEquals(1.0, matchingApi.calculateDistanceScore(0), 0.01);

        // Max distance should return 0.0
        assertEquals(0.0, matchingApi.calculateDistanceScore(50.0), 0.01);

        // Half distance should return 0.5
        assertEquals(0.5, matchingApi.calculateDistanceScore(25.0), 0.01);
    }

    @Test
    public void testFindCommonInterests() {
        List<String> interests1 = Arrays.asList("music", "sports", "gaming");
        List<String> interests2 = Arrays.asList("music", "reading", "sports");

        List<String> common = matchingApi.findCommonInterests(interests1, interests2);

        assertEquals(2, common.size(), "Should have 2 common interests");
        assertTrue(common.contains("music"), "Should contain music");
        assertTrue(common.contains("sports"), "Should contain sports");
    }

    @Test
    public void testCalculateMatchScore() {
        List<String> userInterests = Arrays.asList("music", "sports");
        List<String> otherInterests = Arrays.asList("music", "sports", "gaming");

        double score = matchingApi.calculateMatchScore(
            userInterests,
            otherInterests,
            5.0, // 5km distance
            0.8  // activity score
        );

        // Score should be between 0 and 1
        assertTrue(score > 0 && score <= 1.0, "Score should be between 0 and 1");
    }
}
