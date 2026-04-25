/// Interest Tag Model for GlowStar
/// 
/// Represents a user's interest for matching and discovery
class InterestTag {
  final String id;
  final String name;
  final String category;
  final String icon;
  final bool isSelected;

  InterestTag({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'isSelected': isSelected,
    };
  }

  factory InterestTag.fromJson(Map<String, dynamic> json) {
    return InterestTag(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  InterestTag copyWith({bool? isSelected}) {
    return InterestTag(
      id: id,
      name: name,
      category: category,
      icon: icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Interest Categories for GlowStar
class InterestCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'music',
      'name': 'Music',
      'icon': '🎵',
      'tags': ['Pop', 'Rock', 'Hip Hop', 'Classical', 'Jazz', 'Electronic', 'R&B', 'Country']
    },
    {
      'id': 'sports',
      'name': 'Sports',
      'icon': '⚽',
      'tags': ['Football', 'Basketball', 'Tennis', 'Swimming', 'Running', 'Yoga', 'Cycling', 'Gym']
    },
    {
      'id': 'gaming',
      'name': 'Gaming',
      'icon': '🎮',
      'tags': ['FPS', 'RPG', 'Strategy', 'Sports Games', 'Mobile Games', 'PC Games', 'Console', 'Indie']
    },
    {
      'id': 'reading',
      'name': 'Reading',
      'icon': '📚',
      'tags': ['Fiction', 'Non-fiction', 'Science', 'History', 'Philosophy', 'Poetry', 'Comics', 'Manga']
    },
    {
      'id': 'art',
      'name': 'Art',
      'icon': '🎨',
      'tags': ['Painting', 'Drawing', 'Photography', 'Design', 'Sculpture', 'Digital Art', 'Crafts', 'Calligraphy']
    },
    {
      'id': 'food',
      'name': 'Food',
      'icon': '🍜',
      'tags': ['Cooking', 'Baking', 'Street Food', 'Fine Dining', 'Vegetarian', 'Vegan', 'Coffee', 'Tea']
    },
    {
      'id': 'travel',
      'name': 'Travel',
      'icon': '✈️',
      'tags': ['Backpacking', 'Luxury', 'Adventure', 'Cultural', 'Beach', 'Mountain', 'City', 'Nature']
    },
    {
      'id': 'tech',
      'name': 'Technology',
      'icon': '💻',
      'tags': ['Programming', 'AI', 'Blockchain', 'Gadgets', 'Startups', 'Science', 'Robotics', 'VR/AR']
    },
    {
      'id': 'movies',
      'name': 'Movies & TV',
      'icon': '🎬',
      'tags': ['Action', 'Comedy', 'Drama', 'Sci-fi', 'Horror', 'Documentary', 'Anime', 'Series']
    },
    {
      'id': 'study',
      'name': 'Study',
      'icon': '📖',
      'tags': ['Math', 'Physics', 'Chemistry', 'English', 'History', 'Geography', 'Biology', 'Computer Science']
    },
    {
      'id': 'social',
      'name': 'Social',
      'icon': '👥',
      'tags': ['Networking', 'Volunteering', 'Community', 'Events', 'Parties', 'Meetups', 'Clubs', 'Organizations']
    },
    {
      'id': 'fitness',
      'name': 'Fitness',
      'icon': '💪',
      'tags': ['Cardio', 'Strength', 'Martial Arts', 'Dance', 'Hiking', 'Climbing', 'Skating', 'Surfing']
    },
  ];

  static List<InterestTag> getAllTags() {
    List<InterestTag> allTags = [];
    for (var category in categories) {
      for (var tag in category['tags']) {
        allTags.add(InterestTag(
          id: '${category['id']}_$tag'.toLowerCase().replaceAll(' ', '_'),
          name: tag,
          category: category['name'],
          icon: category['icon'],
        ));
      }
    }
    return allTags;
  }

  static List<String> getTagsByCategory(String categoryId) {
    for (var category in categories) {
      if (category['id'] == categoryId) {
        return List<String>.from(category['tags']);
      }
    }
    return [];
  }
}
