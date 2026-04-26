import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:glowstar/screens/login_screen.dart';
import 'package:glowstar/screens/main_screen.dart';
import 'package:glowstar/screens/feed_screen.dart';
import 'package:glowstar/screens/voice_rooms_screen.dart';
import 'package:glowstar/screens/voice_card_screen.dart';
import 'package:glowstar/screens/level_screen.dart';
import 'package:glowstar/screens/interest_card_screen.dart';
import 'package:glowstar/screens/night_mode_screen.dart';
import 'package:glowstar/model/user_level.dart';

void main(String env) async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("${env}.glowstar.json");
  
  runApp(MaterialApp(
    title: '发光星球 GlowStar',
    initialRoute: '/login',
    routes: {
      '/': (context) => MainScreen(),
      '/login': (context) => LoginView(),
      '/feed': (context) => FeedScreen(
        userId: ModalRoute.of(context)!.settings.arguments['userId'],
        postService: ModalRoute.of(context)!.settings.arguments['postService'],
      ),
      '/voice-rooms': (context) => VoiceRoomsScreen(),
      '/voice-card': (context) => VoiceCardScreen(
        userId: ModalRoute.of(context)!.settings.arguments['userId'],
      ),
      '/level': (context) => LevelScreen(
        userLevel: ModalRoute.of(context)!.settings.arguments['userLevel'],
        achievements: [],
      ),
      '/interest-card': (context) => InterestCardScreen(
        userId: ModalRoute.of(context)!.settings.arguments['userId'],
        nickname: ModalRoute.of(context)!.settings.arguments['nickname'],
        interests: ModalRoute.of(context)!.settings.arguments['interests'],
      ),
      '/night-mode': (context) => NightModeScreen(
        userId: ModalRoute.of(context)!.settings.arguments['userId'],
      ),
    },
    supportedLocales: const [
      Locale('zh'), // Chinese
      Locale('en'), // English
    ],
    locale: const Locale('zh'),
    theme: ThemeData(
      primarySwatch: Colors.purple,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
