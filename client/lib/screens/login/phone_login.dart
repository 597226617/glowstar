import 'package:flutter/material.dart';

/// Phone Login Screen for GlowStar
/// 
/// Phone number + SMS verification code login
class PhoneLoginScreen extends StatefulWidget {
  final Function(String userId, String phone) onSuccess;

  const PhoneLoginScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isSendingCode = false;
  bool _isLoggingIn = false;
  int _countdown = 0;
  String? _error;

  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11 || !phone.startsWith('1')) {
      setState(() => _error = '请输入正确的手机号');
      return;
    }
    setState(() {
      _isSendingCode = true;
      _error = null;
    });
    try {
      // In real implementation: call SMS API
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _countdown = 60);
      _startCountdown();
    } catch (e) {
      setState(() => _error = '发送失败: $e');
    }
    setState(() => _isSendingCode = false);
  }

  void _startCountdown() async {
    while (_countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _countdown--);
    }
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.length != 11 || code.length != 6) {
      setState(() => _error = '请检查手机号和验证码');
      return;
    }
    setState(() {
      _isLoggingIn = true;
      _error = null;
    });
    try {
      // In real implementation: call login API with phone + code
      await Future.delayed(const Duration(seconds: 2));
      widget.onSuccess('phone_${phone}', phone);
    } catch (e) {
      setState(() => _error = '登录失败: $e');
    }
    setState(() => _isLoggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手机号登录')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(Icons.phone_android, size: 60, color: Colors.purple.withOpacity(0.7)),
              const SizedBox(height: 16),
              const Text('手机号登录', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              // Phone number
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  labelText: '手机号',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+86 ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              // Verification code
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: '验证码',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: _countdown > 0 || _isSendingCode ? null : _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(0, 56),
                      ),
                      child: _isSendingCode
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : Text(
                              _countdown > 0 ? '${_countdown}s' : '获取验证码',
                              style: const TextStyle(fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoggingIn ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoggingIn
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Text('登录', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '登录即表示同意《用户协议》和《隐私政策》',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
