import 'package:flutter/material.dart';

/// Localization Service for GlowStar
/// 
/// Supports multiple languages and regional settings
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, Map<String, String>> _translations = {
    'zh-CN': {
      'app_name': '发光星球',
      'home': '首页',
      'messages': '消息',
      'groups': '小组',
      'profile': '个人中心',
      'settings': '设置',
      'search': '搜索',
      'notifications': '通知',
      'ai_assistant': 'AI 助手',
      'study_groups': '学习小组',
      'interests': '兴趣爱好',
      'subjects': '学科标签',
      'match': '匹配',
      'chat': '聊天',
      'login': '登录',
      'register': '注册',
      'logout': '退出登录',
      'delete_account': '删除账户',
      'help': '帮助',
      'about': '关于',
      'privacy': '隐私',
      'security': '安全',
      'dark_mode': '深色模式',
      'language': '语言',
      'theme': '主题',
      'online_status': '在线状态',
      'location': '位置',
      'max_distance': '最大距离',
      'sound': '声音',
      'vibration': '震动',
    },
    'en-US': {
      'app_name': 'GlowStar',
      'home': 'Home',
      'messages': 'Messages',
      'groups': 'Groups',
      'profile': 'Profile',
      'settings': 'Settings',
      'search': 'Search',
      'notifications': 'Notifications',
      'ai_assistant': 'AI Assistant',
      'study_groups': 'Study Groups',
      'interests': 'Interests',
      'subjects': 'Subjects',
      'match': 'Match',
      'chat': 'Chat',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      'help': 'Help',
      'about': 'About',
      'privacy': 'Privacy',
      'security': 'Security',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'theme': 'Theme',
      'online_status': 'Online Status',
      'location': 'Location',
      'max_distance': 'Max Distance',
      'sound': 'Sound',
      'vibration': 'Vibration',
    },
  };

  String _currentLanguage = 'zh-CN';

  /// Set current language
  void setLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
    }
  }

  /// Get current language
  String getCurrentLanguage() => _currentLanguage;

  /// Get translation
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  /// Get all supported languages
  List<String> getSupportedLanguages() => _translations.keys.toList();

  /// Get language name
  String getLanguageName(String languageCode) {
    Map<String, String> names = {
      'zh-CN': '简体中文',
      'en-US': 'English',
    };
    return names[languageCode] ?? languageCode;
  }
}
