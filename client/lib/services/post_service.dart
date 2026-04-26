import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post.dart';

/// Post Service for GlowStar Content Feed
/// Handles feed loading, post creation, likes, comments
class PostService {
  final String baseUrl;
  final Map<String, String>? headers;

  PostService({required this.baseUrl, this.headers});

  /// Get personalized feed
  Future<List<Post>> getFeed({int page = 0, int limit = 20, required String userId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/feed?userId=$userId&page=$page&limit=$limit'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List postsJson = data['posts'] as List;
      return postsJson.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Failed to load feed: ${response.statusCode}');
  }

  /// Create a new post
  Future<String> createPost({
    required String userId,
    required String content,
    String type = 'text',
    String? mediaUrl,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/posts'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'content': content,
        'type': type,
        'mediaUrl': mediaUrl,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as String;
    }
    throw Exception('Failed to create post: ${response.statusCode}');
  }

  /// Toggle like on a post
  Future<bool> toggleLike({required String postId, required String userId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/posts/$postId/like'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['liked'] as bool;
    }
    throw Exception('Failed to toggle like');
  }

  /// Add comment to a post
  Future<String> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/posts/$postId/comment'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'content': content}),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as String;
    }
    throw Exception('Failed to add comment');
  }

  /// Get single post with comments
  Future<Map<String, dynamic>> getPost(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/posts/$postId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load post');
  }

  /// Follow/unfollow a user
  Future<bool> toggleFollow({required String targetUserId, required String currentUserId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$targetUserId/follow'),
      headers: {...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'followerId': currentUserId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['following'] as bool;
    }
    throw Exception('Failed to toggle follow');
  }
}
