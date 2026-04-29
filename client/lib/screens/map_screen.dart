import 'package:flutter/material.dart';
import 'package:glowstar/model/interest_tag.dart';
import 'package:glowstar/services/matching_service.dart';

/// Map Screen for GlowStar
/// 
/// Shows nearby users with breathing light animation
/// and interest-based markers
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  List<Map<String, dynamic>> _nearbyUsers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
    
    _loadNearbyUsers();
  }

  void _loadNearbyUsers() {
    // Simulate nearby users
    setState(() {
      _nearbyUsers = [
        {
          'id': 'user1',
          'name': '小明',
          'avatar': 'https://example.com/avatar1.jpg',
          'latitude': 39.9042,
          'longitude': 116.4074,
          'interests': [
            InterestTag(id: 'music_pop', name: 'Pop', category: 'Music', icon: '🎵'),
            InterestTag(id: 'sports_football', name: 'Football', category: 'Sports', icon: '⚽'),
          ],
          'distance': 1.2,
          'isOnline': true,
        },
        {
          'id': 'user2',
          'name': '小红',
          'avatar': 'https://example.com/avatar2.jpg',
          'latitude': 39.9142,
          'longitude': 116.4174,
          'interests': [
            InterestTag(id: 'reading_fiction', name: 'Fiction', category: 'Reading', icon: '📚'),
            InterestTag(id: 'study_math', name: 'Math', category: 'Study', icon: '📖'),
          ],
          'distance': 2.5,
          'isOnline': true,
        },
      ];
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background (placeholder)
          Container(
            color: Colors.blue[50],
            child: Center(
              child: Text('地图加载中...', style: TextStyle(color: Colors.grey)),
            ),
          ),
          
          // User markers
          ..._nearbyUsers.map((user) => _buildUserMarker(user)),
          
          // User info panel
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildInfoPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMarker(Map<String, dynamic> user) {
    // In real implementation, this would use a map SDK
    // For now, just show placeholder markers
    return Positioned(
      top: 100 + (user['distance'] * 50),
      left: 50 + (user['distance'] * 30),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getInterestColor(user['interests'][0].category),
                boxShadow: [
                  BoxShadow(
                    color: _getInterestColor(user['interests'][0].category).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
                radius: 25,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getInterestColor(String category) {
    switch (category.toLowerCase()) {
      case 'music': return Colors.purple;
      case 'sports': return Colors.orange;
      case 'gaming': return Colors.red;
      case 'reading': return Colors.blue;
      case 'art': return Colors.pink;
      case 'food': return Colors.brown;
      case 'travel': return Colors.teal;
      case 'tech': return Colors.cyan;
      case 'movies': return Colors.indigo;
      case 'study': return Colors.green;
      case 'social': return Colors.amber;
      case 'fitness': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '附近 ${_nearbyUsers.length} 个发光星球',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '点击光点查看详情，找到你的同好！',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
