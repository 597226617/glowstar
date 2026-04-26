import 'package:flutter/material.dart';

/// WeChat Login Screen for GlowStar
/// 
/// Supports WeChat OAuth login for Chinese users
class WeChatLoginScreen extends StatefulWidget {
  final Function(String userId, String nickname, String? avatar) onSuccess;

  const WeChatLoginScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _WeChatLoginScreenState createState() => _WeChatLoginScreenState();
}

class _WeChatLoginScreenState extends State<WeChatLoginScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _loginWithWeChat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // In real implementation: use wechat_seoalk plugin
      // final result = await WechatAuthSDK.login(...);
      await Future.delayed(const Duration(seconds: 2));
      // Simulate successful login
      widget.onSuccess(
        'wx_${DateTime.now().millisecondsSinceEpoch}',
        '微信用户',
        'https://example.com/avatar.jpg',
      );
    } catch (e) {
      setState(() => _error = '登录失败: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.chat, size: 80, color: const Color(0xFF07C160)),
              const SizedBox(height: 16),
              const Text(
                '微信登录',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '使用微信账号登录发光星球',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithWeChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07C160),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, color: Colors.white),
                            SizedBox(width: 8),
                            Text('微信登录', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
