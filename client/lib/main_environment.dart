import 'package:flutter/material.dart';
import 'package:glowstar/screens/login_screen.dart';
import 'package:glowstar/screens/main_screen.dart';
import 'package:glowstar/screens/chat_screen.dart';
import 'package:glowstar/screens/feed_screen.dart';
import 'package:glowstar/screens/voice_rooms_screen.dart';
import 'package:glowstar/screens/voice_card_screen.dart';
import 'package:glowstar/screens/level_screen.dart';
import 'package:glowstar/screens/interest_card_screen.dart';
import 'package:glowstar/screens/daily_match_screen.dart';
import 'package:glowstar/screens/map_screen.dart';
import 'package:glowstar/services/matching_service.dart';

void main(String env) {
  final baseUrl = env == 'prod' 
      ? 'https://api.glowstar.app' 
      : 'http://10.0.2.2:8080';
  
  runApp(GlowStarApp(baseUrl: baseUrl));
}

class GlowStarApp extends StatelessWidget {
  final String baseUrl;

  const GlowStarApp({Key? key, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '发光星球 GlowStar',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/main': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return MainScreen(
            userId: args['userId'] as String? ?? '',
            nickname: args['nickname'] as String?,
            avatar: args['avatar'] as String?,
          );
        },
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return ChatScreen(
            userId: args['userId'] as String? ?? '',
            targetUserId: args['targetUserId'] as String? ?? '',
            targetNickname: args['targetNickname'] as String? ?? '用户',
            matchReason: args['matchReason'] as String?,
          );
        },
        '/feed': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return FeedScreen(
            userId: args['userId'] as String? ?? '',
            postService: args['postService'],
          );
        },
        '/voice-rooms': (context) => VoiceRoomsScreen(),
        '/voice-card': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return VoiceCardScreen(userId: args['userId'] as String? ?? '');
        },
        '/level': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return LevelScreen(
            userLevel: args['userLevel'],
            achievements: [],
          );
        },
        '/interest-card': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return InterestCardScreen(
            userId: args['userId'] as String? ?? '',
            nickname: args['nickname'] as String? ?? '',
            interests: args['interests'] as List? ?? [],
          );
        },
        '/daily-match': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return DailyMatchScreen(
            userId: args['userId'] as String? ?? '',
            matchingService: MatchingService(baseUrl: baseUrl),
          );
        },
      },
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      locale: const Locale('zh'),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF9C27B0),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9C27B0),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // GlowStar specific theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          brightness: Brightness.light,
        ),
      ),
    );
  }
}
