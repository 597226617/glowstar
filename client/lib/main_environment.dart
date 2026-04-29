import 'package:flutter/material.dart';
import 'package:glowstar/constants/app_constants.dart';
import 'package:glowstar/router/app_router.dart';
import 'package:glowstar/widgets/app_widgets.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/voice_rooms_screen.dart';
import 'screens/voice_card_screen.dart';
import 'screens/level_screen.dart';
import 'screens/interest_card_screen.dart';
import 'screens/daily_match_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/night_mode_screen.dart';
import 'screens/search_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/study_groups_screen.dart';
import 'services/matching_service.dart';

void main(String env) {
  WidgetsFlutterBinding.ensureInitialized();
  AppErrorHandler().init();

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
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,
      supportedLocales: const [Locale('zh'), Locale('en')],
      locale: const Locale('zh'),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
