import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../model/interest_tag.dart';

/// Interest Card Screen for GlowStar
/// 
/// Generate beautiful shareable interest cards
/// Users can share their top interests as visual cards
class InterestCardScreen extends StatefulWidget {
  final String userId;
  final String nickname;
  final List<InterestTag> interests;

  const InterestCardScreen({
    Key? key,
    required this.userId,
    required this.nickname,
    required this.interests,
  }) : super(key: key);

  @override
  _InterestCardScreenState createState() => _InterestCardScreenState();
}

class _InterestCardScreenState extends State<InterestCardScreen> {
  int _selectedTheme = 0;
  final GlobalKey _cardKey = GlobalKey();

  final List<Map<String, dynamic>> _themes = [
    {
      'name': '星空',
      'gradient': [Colors.purple, Colors.blue],
      'bg': '🌌',
    },
    {
      'name': '海洋',
      'gradient': [Colors.cyan, Colors.blue],
      'bg': '🌊',
    },
    {
      'name': '日落',
      'gradient': [Colors.orange, Colors.red],
      'bg': '🌅',
    },
    {
      'name': '森林',
      'gradient': [Colors.green, Colors.teal],
      'bg': '🌲',
    },
    {
      'name': '樱花',
      'gradient': [Colors.pink, Colors.purple],
      'bg': '🌸',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_selectedTheme];
    final topInterests = widget.interests.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('兴趣卡片'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveCard(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCard(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Card preview
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _cardKey,
                child: Container(
                  width: 300,
                  height: 420,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (theme['gradient'] as List<Color>)[0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background decoration
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Text(
                          theme['bg'] as String,
                          style: const TextStyle(fontSize: 120, opacity: 0.2),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  '发光星球',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Nickname
                            Text(
                              widget.nickname,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '我的兴趣标签',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            // Interest tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: topInterests.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(tag.icon, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 4),
                                      Text(
                                        tag.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const Spacer(),
                            // Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '找到 ${topInterests.length} 个兴趣同好',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.qr_code, size: 24, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Theme selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('选择主题', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _themes.asMap().entries.map((entry) {
                    final i = entry.key;
                    final theme = entry.value;
                    final isSelected = i == _selectedTheme;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTheme = i),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: theme['gradient'] as List<Color>,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? Colors.purple : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(theme['bg'] as String, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme['name'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.purple : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCard(BuildContext context) async {
    // In real implementation: use screenshot package to save image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('卡片已保存到相册 📸')),
    );
  }

  Future<void> _shareCard(BuildContext context) async {
    // In real implementation: use share package
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('分享到', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption('微信', Icons.chat, const Color(0xFF07C160)),
                _buildShareOption('朋友圈', Icons.account_circle, const Color(0xFF07C160)),
                _buildShareOption('QQ', '🐧', Colors.blue),
                _buildShareOption('微博', '📢', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String label, dynamic icon, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: icon is IconData
              ? Icon(icon, color: Colors.white, size: 28)
              : Text(icon as String, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
