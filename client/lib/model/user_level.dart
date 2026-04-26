/// User Level model for GlowStar Gamification
class UserLevel {
  final String userId;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalHelps;
  final int totalMatches;
  final int streakDays;
  final DateTime lastActiveDate;

  UserLevel({
    required this.userId,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    this.totalPosts = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalHelps = 0,
    this.totalMatches = 0,
    this.streakDays = 0,
    required this.lastActiveDate,
  });

  /// XP required for each level
  static int xpForLevel(int level) {
    return (level * 100 + level * level * 10).toInt();
  }

  double get progressPercent => xp / xpToNextLevel;

  /// Get level title
  String get levelTitle {
    if (level >= 20) return '发光大师';
    if (level >= 15) return '闪耀之星';
    if (level >= 10) return '明亮之光';
    if (level >= 7) return '初发光';
    if (level >= 5) return '微光';
    if (level >= 3) return '萤火';
    return '星光';
  }

  /// Get level emoji
  String get levelEmoji {
    if (level >= 20) return '🌟';
    if (level >= 15) return '✨';
    if (level >= 10) return '💫';
    if (level >= 7) return '🌠';
    if (level >= 5) return '⭐';
    if (level >= 3) return '🔆';
    return '🌑';
  }

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      userId: json['userId'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? xpForLevel(json['level'] as int? ?? 1),
      totalPosts: json['totalPosts'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
      totalHelps: json['totalHelps'] as int? ?? 0,
      totalMatches: json['totalMatches'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'level': level,
    'xp': xp,
    'xpToNextLevel': xpToNextLevel,
    'totalPosts': totalPosts,
    'totalLikes': totalLikes,
    'totalComments': totalComments,
    'totalHelps': totalHelps,
    'totalMatches': totalMatches,
    'streakDays': streakDays,
    'lastActiveDate': lastActiveDate.toIso8601String(),
  };
}

/// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.xpReward = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// All available achievements
  static List<Achievement> getAllAchievements() {
    return [
      Achievement(id: 'first_post', name: '初次发光', description: '发布第一条动态', icon: '📝', xpReward: 50),
      Achievement(id: 'ten_posts', name: '内容达人', description: '发布 10 条动态', icon: '✏️', xpReward: 100),
      Achievement(id: 'fifty_posts', name: '创作之星', description: '发布 50 条动态', icon: '🌟', xpReward: 200),
      Achievement(id: 'first_like', name: '获得认可', description: '收到第一个赞', icon: '❤️', xpReward: 20),
      Achievement(id: 'ten_likes', name: '人气之星', description: '累计收到 10 个赞', icon: '💖', xpReward: 50),
      Achievement(id: 'hundred_likes', name: '闪耀明星', description: '累计收到 100 个赞', icon: '🏆', xpReward: 150),
      Achievement(id: 'first_comment', name: '互动新手', description: '发表第一条评论', icon: '💬', xpReward: 10),
      Achievement(id: 'first_match', name: '找到同好', description: '第一次匹配成功', icon: '🤝', xpReward: 30),
      Achievement(id: 'ten_matches', name: '社交达人', description: '匹配 10 个好友', icon: '🎉', xpReward: 100),
      Achievement(id: 'first_help', name: '热心肠', description: '第一次帮助他人', icon: '🤗', xpReward: 40),
      Achievement(id: 'ten_helps', name: '学霸认证', description: '帮助 10 人答疑', icon: '🎓', xpReward: 100),
      Achievement(id: 'streak_7', name: '坚持一周', description: '连续活跃 7 天', icon: '📅', xpReward: 70),
      Achievement(id: 'streak_30', name: '月度达人', description: '连续活跃 30 天', icon: '🗓️', xpReward: 200),
      Achievement(id: 'voice_card', name: '声音名片', description: '录制声音名片', icon: '🎙️', xpReward: 30),
      Achievement(id: 'voice_room', name: '语音达人', description: '参加语音房间', icon: '🎧', xpReward: 25),
      Achievement(id: 'study_group', name: '学习小组', description: '加入学习小组', icon: '📚', xpReward: 20),
      Achievement(id: 'night_owl', name: '夜猫子', description: '深夜 23:00 后活跃', icon: '🦉', xpReward: 15),
      Achievement(id: 'early_bird', name: '早起鸟', description: '早上 6:00 前活跃', icon: '🐦', xpReward: 15),
      Achievement(id: 'verified', name: '实名认证', description: '完成身份认证', icon: '✅', xpReward: 50),
      Achievement(id: 'level_10', name: '发光之星', description: '达到 10 级', icon: '🌟', xpReward: 300),
    ];
  }
}
