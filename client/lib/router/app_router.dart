import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/voice_rooms_screen.dart';
import '../screens/voice_card_screen.dart';
import '../screens/level_screen.dart';
import '../screens/interest_card_screen.dart';
import '../screens/daily_match_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/night_mode_screen.dart';
import '../screens/search_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/study_groups_screen.dart';
import '../widgets/app_widgets.dart';

/// App router - centralized navigation management
class AppRouter {
  static const String login = '/login';
  static const String main = '/main';
  static const String chat = '/chat';
  static const String voiceRooms = '/voice-rooms';
  static const String voiceCard = '/voice-card';
  static const String level = '/level';
  static const String interestCard = '/interest-card';
  static const String dailyMatch = '/daily-match';
  static const String aiAssistant = '/ai-assistant';
  static const String nightMode = '/night-mode';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String studyGroups = '/study-groups';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginView());
      case main:
        return _fadeRoute(const MainScreen());
      case chat:
        return _fadeRoute(ChatScreen(
          userId: args['userId'] ?? '',
          targetUserId: args['targetUserId'] ?? '',
          targetNickname: args['targetNickname'] ?? '用户',
          matchReason: args['matchReason'],
        ));
      case voiceRooms:
        return _fadeRoute(const VoiceRoomsScreen());
      case voiceCard:
        return _fadeRoute(VoiceCardScreen(userId: args['userId'] ?? ''));
      case level:
        return _fadeRoute(LevelScreen(
          userLevel: args['userLevel'],
          achievements: args['achievements'] ?? [],
        ));
      case interestCard:
        return _fadeRoute(InterestCardScreen(
          userId: args['userId'] ?? '',
          nickname: args['nickname'] ?? '',
          interests: args['interests'] ?? [],
        ));
      case dailyMatch:
        return _fadeRoute(DailyMatchScreen(
          userId: args['userId'] ?? '',
        ));
      case aiAssistant:
        return _fadeRoute(const AiAssistantScreen());
      case nightMode:
        return _fadeRoute(const NightModeScreen());
      case search:
        return _fadeRoute(const SearchScreen());
      case notifications:
        return _fadeRoute(const NotificationsScreen());
      case settings:
        return _fadeRoute(const SettingsScreen());
      case studyGroups:
        return _fadeRoute(const StudyGroupsScreen());
      default:
        return _fadeRoute(ErrorWidget(message: '页面不存在'));
    }
  }

  static MaterialPageRoute _fadeRoute(Widget child) {
    return MaterialPageRoute(
      builder: (_) => child,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
