/// Post model for GlowStar Content Feed
class Post {
  final String id;
  final String userId;
  final String nickname;
  final String? avatar;
  final String? bio;
  final String content;
  final String type; // text, image, video, voice
  final String? mediaUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isFollowing;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final List<String>? tags;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.nickname,
    this.avatar,
    this.bio,
    required this.content,
    this.type = 'text',
    this.mediaUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isFollowing = false,
    this.latitude,
    this.longitude,
    this.locationName,
    this.tags,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nickname': nickname,
      'avatar': avatar,
      'bio': bio,
      'content': content,
      'type': type,
      'mediaUrl': mediaUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'isLiked': isLiked,
      'isFollowing': isFollowing,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? avatar,
    String? bio,
    String? content,
    String? type,
    String? mediaUrl,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    bool? isFollowing,
    double? latitude,
    double? longitude,
    String? locationName,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
