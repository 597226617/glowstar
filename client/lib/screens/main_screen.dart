import 'package:flutter/material.dart';
import 'package:glowstar/screens/map_screen.dart';
import 'package:glowstar/screens/daily_match_screen.dart';
import 'package:glowstar/screens/feed_screen.dart';
import 'package:glowstar/screens/conversations_screen.dart';
import 'package:glowstar/screens/profile_screen.dart';
import 'package:glowstar/services/matching_service.dart';

/// Main Screen for GlowStar
/// 
/// Navigation tabs:
/// 0 - 🗺️ 星球地图 (Map with breathing light markers)
/// 1 - ✨ 今日推荐 (Daily matches, max 10)
/// 2 - 💬 消息 (Conversations)
/// 3 - 👤 我的 (Profile)
class MainScreen extends StatefulWidget {
  final String userId;
  final String? nickname;
  final String? avatar;

  const MainScreen({
    Key? key,
    required this.userId,
    this.nickname,
    this.avatar,
  }) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late MatchingService _matchingService;
  
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _matchingService = MatchingService(baseUrl: 'http://10.0.2.2:8080'); // Android emulator
    
    _screens = [
      MapScreen(
        userId: widget.userId,
        matchingService: _matchingService,
      ),
      DailyMatchScreen(
        userId: widget.userId,
        matchingService: _matchingService,
      ),
      ConversationsForm(),
      _buildProfileScreen(),
    ];
  }

  Widget _buildProfileScreen() {
    return ProfileForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: '星球',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: '推荐',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: '消息',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF9C27B0), // Purple - GlowStar theme
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _matchingService.dispose();
    super.dispose();
  }
}
