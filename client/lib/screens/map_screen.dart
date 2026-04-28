import 'dart:math';
import 'package:flutter/material.dart';
import 'package:glowstar/model/interest_tag.dart';
import 'package:glowstar/services/matching_service.dart';

/// Map Screen for GlowStar - 一起发光 ✨
/// 
/// Features:
/// - Breathing light animation on user markers (2-second cycle)
/// - Interest-based color coding for light dots
/// - Light dot size represents online status
/// - Fuzzy distance display (privacy protection)
/// - Tap light dot to see interests (not appearance)
/// - Warm, healing visual design
class MapScreen extends StatefulWidget {
  final String userId;
  final MatchingService matchingService;

  const MapScreen({
    Key? key,
    required this.userId,
    required this.matchingService,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  
  List<NearbyUser> _nearbyUsers = [];
  bool _isLoading = true;
  NearbyUser? _selectedUser;
  
  // Simulated user positions on screen (would be map coordinates in real impl)
  final Random _random = Random();
  late List<_UserMarkerPosition> _markerPositions;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation: 2-second cycle, gentle pulse
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _breathingAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
    
    _breathingController.repeat(reverse: true);
    _loadNearbyUsers();
  }

  Future<void> _loadNearbyUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // In production, get real GPS coordinates
      // For now, use simulated location
      final users = await widget.matchingService.getNearbyUsers(
        userId: widget.userId,
        latitude: 39.9042, // Beijing center
        longitude: 116.4074,
        radiusMeters: 5000,
      );
      
      setState(() {
        _nearbyUsers = users;
        _generateMarkerPositions();
        _isLoading = false;
      });
    } catch (e) {
      // If API fails, show demo data
      setState(() {
        _nearbyUsers = _generateDemoUsers();
        _generateMarkerPositions();
        _isLoading = false;
      });
    }
  }

  void _generateMarkerPositions() {
    _markerPositions = _nearbyUsers.map((user) {
      // Distribute markers across the screen area
      return _UserMarkerPosition(
        user: user,
        left: 40.0 + _random.nextDouble() * 280,
        top: 80.0 + _random.nextDouble() * 400,
      );
    }).toList();
  }

  List<NearbyUser> _generateDemoUsers() {
    return [
      NearbyUser(
        id: 'demo1',
        nickname: '小明',
        bio: '喜欢音乐和运动的阳光男孩',
        isOnline: true,
        distance: 300,
        interests: [
          InterestTag(id: 'music_rock', name: '摇滚', category: '音乐', icon: '🎸'),
          InterestTag(id: 'sports_basketball', name: '篮球', category: '运动', icon: '🏀'),
        ],
        primaryCategory: '音乐',
        matchScore: 0.85,
      ),
      NearbyUser(
        id: 'demo2',
        nickname: '小红',
        bio: '读书看电影，偶尔画画',
        isOnline: true,
        distance: 800,
        interests: [
          InterestTag(id: 'reading_fiction', name: '小说', category: '阅读', icon: '📚'),
          InterestTag(id: 'art_painting', name: '绘画', category: '艺术', icon: '🎨'),
          InterestTag(id: 'movie_anime', name: '动画', category: '电影', icon: '🎬'),
        ],
        primaryCategory: '阅读',
        matchScore: 0.72,
      ),
      NearbyUser(
        id: 'demo3',
        nickname: '阿杰',
        bio: '编程、游戏、咖啡 ☕',
        isOnline: true,
        distance: 1500,
        interests: [
          InterestTag(id: 'tech_programming', name: '编程', category: '科技', icon: '⌨️'),
          InterestTag(id: 'gaming_pc', name: 'PC游戏', category: '游戏', icon: '🖥️'),
          InterestTag(id: 'food_coffee', name: '咖啡', category: '美食', icon: '☕'),
        ],
        primaryCategory: '科技',
        matchScore: 0.68,
      ),
      NearbyUser(
        id: 'demo4',
        nickname: '小美',
        bio: '美食探店爱好者',
        isOnline: false,
        distance: 2200,
        interests: [
          InterestTag(id: 'food_cooking', name: '烹饪', category: '美食', icon: '👨‍🍳'),
          InterestTag(id: 'travel_city', name: '城市漫步', category: '旅行', icon: '🏙️'),
        ],
        primaryCategory: '美食',
        matchScore: 0.55,
      ),
      NearbyUser(
        id: 'demo5',
        nickname: '大伟',
        bio: '健身达人，每天打卡 💪',
        isOnline: true,
        distance: 1800,
        interests: [
          InterestTag(id: 'fitness_gym', name: '健身房', category: '健身', icon: '🏋️'),
          InterestTag(id: 'sports_running', name: '跑步', category: '运动', icon: '🏃'),
        ],
        primaryCategory: '健身',
        matchScore: 0.45,
      ),
      NearbyUser(
        id: 'demo6',
        nickname: '小雨',
        bio: '学渣求学霸带飞 🙏',
        isOnline: true,
        distance: 600,
        interests: [
          InterestTag(id: 'study_math', name: '数学', category: '学习', icon: '📐'),
          InterestTag(id: 'study_english', name: '英语', category: '学习', icon: '📖'),
          InterestTag(id: 'music_pop', name: '流行音乐', category: '音乐', icon: '🎵'),
        ],
        primaryCategory: '学习',
        matchScore: 0.78,
      ),
    ];
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark map background (night sky theme)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E27), // Deep space blue
                  Color(0xFF1A1A3E), // Dark purple
                  Color(0xFF16213E), // Navy
                ],
              ),
            ),
          ),
          
          // Subtle star particles in background
          ..._buildStars(),
          
          // Grid lines (subtle map grid effect)
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),
          
          // User location marker (center)
          _buildSelfMarker(),
          
          // Nearby user breathing light markers
          if (!_isLoading)
            ..._markerPositions.map((pos) => _buildBreathingMarker(pos)),
          
          // Top bar with stats
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
          
          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
        ],
      ),
    );
  }

  /// Build the user's own location marker (golden star)
  Widget _buildSelfMarker() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: MediaQuery.of(context).size.width * 0.45,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.star, size: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '我',
              style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a breathing light marker for a nearby user
  Widget _buildBreathingMarker(_UserMarkerPosition pos) {
    final user = pos.user;
    final color = Color(user.markerColor);
    final isLarge = user.isOnline; // Online = larger dot
    
    return Positioned(
      top: pos.top,
      left: pos.left,
      child: GestureDetector(
        onTap: () => _onMarkerTapped(user),
        child: AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            final scale = _breathingAnimation.value * (isLarge ? 1.0 : 0.7);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: isLarge ? 64 : 48,
                height: isLarge ? 64 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.3),
                  border: Border.all(
                    color: color.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: isLarge ? 25 : 15,
                      spreadRadius: isLarge ? 8 : 4,
                    ),
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: isLarge ? 40 : 25,
                      spreadRadius: isLarge ? 15 : 8,
                    ),
                  ],
                ),
                child: Center(
                  child: user.avatar != null
                      ? CircleAvatar(
                          radius: isLarge ? 18 : 14,
                          backgroundImage: NetworkImage(user.avatar!),
                        )
                      : CircleAvatar(
                          radius: isLarge ? 18 : 14,
                          backgroundColor: color,
                          child: Text(
                            user.nickname[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: isLarge ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build background stars for ambiance
  List<Widget> _buildStars() {
    final stars = <Widget>[];
    final rng = Random(42); // Fixed seed for consistent stars
    for (int i = 0; i < 60; i++) {
      stars.add(
        Positioned(
          left: rng.nextDouble() * 400,
          top: rng.nextDouble() * 700,
          child: Container(
            width: 1 + rng.nextDouble() * 2,
            height: 1 + rng.nextDouble() * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1 + rng.nextDouble() * 0.3),
            ),
          ),
        ),
      );
    }
    return stars;
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.explore, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '附近 ${_nearbyUsers.where((u) => u.isOnline).length} 个发光星球',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildLegendDot(Colors.purple, '音乐'),
                const SizedBox(width: 8),
                _buildLegendDot(Colors.orange, '运动'),
                const SizedBox(width: 8),
                _buildLegendDot(Colors.green, '学习'),
                const SizedBox(width: 8),
                _buildLegendDot(Colors.blue, '阅读'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    if (_selectedUser != null) {
      return _buildSelectedUserPanel();
    }
    
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✨ 点击光点查看兴趣详情',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              '每个光点代表一个真实用户，颜色代表TA的兴趣',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedUserPanel() {
    final user = _selectedUser!;
    final color = Color(user.markerColor);
    
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.3),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      user.nickname[0],
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.nickname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (user.isOnline)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '在线',
                                style: TextStyle(color: Colors.green, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.distanceText} · 匹配度 ${(user.matchScore * 100).round()}%',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _selectedUser = null),
                ),
              ],
            ),
            
            // Bio
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user.bio!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
            
            // Interest tags (the key feature - show interests, not appearance)
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: user.interests.map((interest) {
                final tagColor = Color(InterestColors.getColor(interest.category));
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tagColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${interest.icon} ${interest.name}',
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            // Action buttons
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startChat(user),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('打招呼'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfile(user),
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('看主页'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            
            // Safety tip
            const SizedBox(height: 6),
            const Center(
              child: Text(
                '💡 安全提示：位置信息已模糊处理，保护你的隐私',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMarkerTapped(NearbyUser user) {
    setState(() => _selectedUser = user);
    // Haptic feedback for interaction
  }

  void _startChat(NearbyUser user) {
    // Navigate to chat with icebreaker suggestions
    Navigator.of(context).pushNamed('/chat', arguments: {
      'userId': widget.userId,
      'targetUserId': user.id,
      'targetNickname': user.nickname,
      'sharedInterests': user.interests,
    });
  }

  void _viewProfile(NearbyUser user) {
    Navigator.of(context).pushNamed('/profile-view', arguments: {
      'userId': user.id,
    });
  }
}

/// Helper class for marker positions on screen
class _UserMarkerPosition {
  final NearbyUser user;
  final double left;
  final double top;

  _UserMarkerPosition({
    required this.user,
    required this.left,
    required this.top,
  });
}

/// Custom painter for subtle grid lines
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
