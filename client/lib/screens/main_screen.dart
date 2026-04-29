import 'package:flutter/material.dart';
import 'package:glowstar/screens/news_screen.dart';
import 'package:glowstar/screens/feed_screen.dart';
import 'package:glowstar/screens/voice_rooms_screen.dart';
import 'package:glowstar/screens/conversations_screen.dart';
import 'package:glowstar/screens/profile_screen.dart';
import 'package:glowstar/services/matching_service.dart';

/// Main Screen for GlowStar
///
/// Navigation tabs:
/// 0 - 🌍 发现 (Discovery / Map)
/// 1 - 📰 动态 (Content Feed)
/// 2 - 🎤 语音房 (Voice Rooms)
/// 3 - 💬 消息 (Conversations)
/// 4 - 👤 我的 (Profile)
class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late MatchingService _matchingService;

  final List<Widget> _widgetOptions = <Widget>[
    const NewsForm(),
    const FeedScreen(),
    const VoiceRoomsScreen(),
    const ConversationsForm(),
    const ProfileForm(),
  ];

  @override
  void initState() {
    super.initState();
    _matchingService = MatchingService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('✨ GlowStar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: '发现',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: '动态',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_outlined),
              activeIcon: Icon(Icons.mic),
              label: '语音房',
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
          selectedItemColor: const Color(0xFF9C27B0),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: _onItemTapped,
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
