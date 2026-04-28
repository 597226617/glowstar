import 'package:flutter/material.dart';
import 'login/phone_login.dart';

/// Login Screen for GlowStar ✨
/// 
/// "让相同兴趣的人，在地图上一起发光"
/// Supports Phone, WeChat, Google, Facebook login
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeInOut),
    );
    _logoAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMethod == 'phone') {
      return PhoneLoginScreen(
        onSuccess: (userId, phone) => _onLoginSuccess(userId, phone),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A3E),
              Color(0xFF2D1B69),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated logo
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.amber],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.star, size: 48, color: Colors.white),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // App name with glow effect
                const Text(
                  '发光星球',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'GlowStar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  '让相同兴趣的人，在地图上一起发光 ✨',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(flex: 3),
                
                // Login buttons
                _buildLoginButton(
                  text: '📱 手机号登录',
                  color: Colors.purple,
                  onTap: () => setState(() => _selectedMethod = 'phone'),
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  text: '💬 微信登录',
                  color: const Color(0xFF07C160),
                  onTap: () {
                    // WeChat login
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('其他登录方式', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Social login icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton('Google', Icons.g_mobilescreen, Colors.red),
                    const SizedBox(width: 32),
                    _buildSocialButton('Facebook', Icons.facebook, const Color(0xFF1877F2)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Terms
                Text(
                  '登录即表示同意《用户协议》和《隐私政策》',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSocialButton(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }

  void _onLoginSuccess(String userId, String nickname) {
    Navigator.of(context).pushReplacementNamed('/main', arguments: {
      'userId': userId,
      'nickname': nickname,
      'avatar': null,
    });
  }
}
