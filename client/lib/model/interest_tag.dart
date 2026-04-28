/// Interest Tag Model for GlowStar
/// 
/// 12 categories with 100+ tags for deep interest matching
class InterestTag {
  final String id;
  final String name;
  final String category;
  final String icon;

  const InterestTag({
    required this.id,
    required this.name,
    required this.category,
    this.icon = '⭐',
  });

  factory InterestTag.fromJson(Map<String, dynamic> json) {
    return InterestTag(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '⭐',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'icon': icon,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestTag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$icon $name ($category)';
}

/// Interest category color mapping for map display
class InterestColors {
  static const Map<String, int> categoryColors = {
    '音乐': 0xFF9C27B0,   // Purple
    '运动': 0xFFFF9800,   // Orange
    '学习': 0xFF4CAF50,   // Green
    '阅读': 0xFF2196F3,   // Blue
    '游戏': 0xFFF44336,   // Red
    '美食': 0xFF795548,   // Brown
    '旅行': 0xFF009688,   // Teal
    '电影': 0xFF3F51B5,   // Indigo
    '艺术': 0xFFE91E63,   // Pink
    '科技': 0xFF00BCD4,   // Cyan
    '社交': 0xFFFFC107,   // Amber
    '健身': 0xFFFF5722,   // Deep Orange
  };

  static int getColor(String category) {
    return categoryColors[category] ?? 0xFF9E9E9E; // Grey default
  }

  static int getColorForTag(InterestTag tag) {
    return getColor(tag.category);
  }
}
