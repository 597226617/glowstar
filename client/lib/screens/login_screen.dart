import 'package:flutter/material.dart';
import 'login/wechat_login.dart';
import 'login/phone_login.dart';

/// Login Screen for GlowStar
/// 
/// Supports WeChat, Phone, Google, Facebook login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    if (_selectedMethod == 'wechat') {
      return WeChatLoginScreen(
        onSuccess: (userId, nickname, avatar) => _onLoginSuccess(userId, nickname, avatar),
      );
    }
    if (_selectedMethod == 'phone') {
      return PhoneLoginScreen(
        onSuccess: (userId, phone) => _onPhoneLoginSuccess(userId, phone),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.star, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                '发光星球 GlowStar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '让相同兴趣的人，在地图上一起发光 ✨',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const Spacer(flex: 3),
              // Login options
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedMethod = 'wechat'),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text('微信登录', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07C160),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedMethod = 'phone'),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('手机号登录', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('其他登录', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),
              // Other options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialLogin('Google', Icons.g_mobilescreen, Colors.red, () {}),
                  const SizedBox(width: 24),
                  _buildSocialLogin('Facebook', Icons.facebook, const Color(0xFF1877F2), () {}),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin(String name, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _onLoginSuccess(String userId, String nickname, String? avatar) {
    // Navigate to main screen
    Navigator.of(context).pushReplacementNamed('/main', arguments: {
      'userId': userId,
      'nickname': nickname,
      'avatar': avatar,
    });
  }

  void _onPhoneLoginSuccess(String userId, String phone) {
    Navigator.of(context).pushReplacementNamed('/main', arguments: {
      'userId': userId,
      'nickname': phone.substring(0, 3) + '****' + phone.substring(7),
      'avatar': null,
    });
  }
}
