import 'package:flutter/material.dart';

/// Night Mode Screen for GlowStar
/// 
/// Activates between 22:00 - 02:00
/// Dark theme + mood matching + night topics
class NightModeScreen extends StatefulWidget {
  final String userId;

  const NightModeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NightModeScreenState createState() => _NightModeScreenState();
}

class _NightModeScreenState extends State<NightModeScreen> {
  String? _selectedMood;
  bool _isMatching = false;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'name': '开心', 'color': Colors.amber},
    {'emoji': '😢', 'name': '难过', 'color': Colors.blue},
    {'emoji': '😰', 'name': '焦虑', 'color': Colors.orange},
    {'emoji': '😴', 'name': '睡不着', 'color': Colors.purple},
    {'emoji': '💭', 'name': '想聊天', 'color': Colors.teal},
    {'emoji': '🤔', 'name': '思考人生', 'color': Colors.indigo},
  ];

  final List<Map<String, dynamic>> _nightTopics = [
    {'title': '说说今天最开心的事', 'emoji': '🌟', 'category': '分享'},
    {'title': '最近有什么烦恼？', 'emoji': '💬', 'category': '倾诉'},
    {'title': '推荐一首睡前音乐', 'emoji': '🎵', 'category': '分享'},
    {'title': '如果明天不用早起...', 'emoji': '🌙', 'category': '想象'},
    {'title': '分享一个冷知识', 'emoji': '🧠', 'category': '知识'},
    {'title': '今天学到了什么？', 'emoji': '📚', 'category': '学习'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: const Color(0xFF16213E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // Stars
                    ...List.generate(20, (i) => Positioned(
                      top: (i * 37) % 180,
                      left: (i * 73) % 350,
                      child: Text('✦', style: TextStyle(
                        color: Colors.white.withOpacity(0.3 + (i % 5) * 0.15),
                        fontSize: 8 + (i % 3) * 4,
                      )),
                    )),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌙', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          const Text(
                            '深夜模式',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '夜深了，说说你的心情',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Mood selection
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💭 你现在的心情', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _moods.map((mood) {
                      final isSelected = _selectedMood == mood['name'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (mood['color'] as Color).withOpacity(0.3)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? mood['color'] as Color
                                  : Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(mood['emoji'] as String, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                mood['name'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Mood match button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedMood != null && !_isMatching ? _startMoodMatch : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isMatching
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))),
                            SizedBox(width: 12),
                            Text('正在匹配同情绪的人...', style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, color: Colors.white),
                            SizedBox(width: 8),
                            Text('匹配同心情的人', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                ),
              ),
            ),
          ),

          // Night topics
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌟 深夜话题', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._nightTopics.map((topic) => Card(
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(topic['emoji'] as String, style: const TextStyle(fontSize: 24)),
                      title: Text(topic['title'] as String, style: const TextStyle(color: Colors.white)),
                      trailing: Chip(
                        label: Text(topic['category'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        backgroundColor: Colors.purple.withOpacity(0.3),
                      ),
                      onTap: () {
                        // Create a post with this topic
                      },
                    ),
                  )),
                ],
              ),
            ),
          ),

          // Night voice rooms
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎧 深夜语音房', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.white.withOpacity(0.05),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.headset, color: Colors.white),
                      ),
                      title: const Text('深夜电台 🌙', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('3/10 人 · 聊聊今天的烦恼', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                        child: const Text('加入', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startMoodMatch() {
    setState(() => _isMatching = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isMatching = false);
        // In real implementation: navigate to chat with matched user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已匹配到和你同心情的人！心情: $_selectedMood')),
        );
      }
    });
  }
}
