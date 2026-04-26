import 'package:flutter/material.dart';
import '../model/user_level.dart';

/// Level & Achievements Screen for GlowStar
/// 
/// Shows user level, XP progress, achievements, and daily quests
class LevelScreen extends StatefulWidget {
  final UserLevel userLevel;
  final List<Achievement> achievements;

  const LevelScreen({
    Key? key,
    required this.userLevel,
    required this.achievements,
  }) : super(key: key);

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  String _selectedTab = '等级';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('等级与成就'),
      ),
      body: Column(
        children: [
          // Level card
          _buildLevelCard(),
          // Tabs
          _buildTabs(),
          // Content
          Expanded(
            child: _selectedTab == '等级'
                ? _buildLevelContent()
                : _selectedTab == '成就'
                    ? _buildAchievementsGrid()
                    : _buildDailyQuests(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Level emoji + number
          Text(widget.userLevel.levelEmoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'Lv.${widget.userLevel.level} ${widget.userLevel.levelTitle}',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // XP progress bar
          LinearProgressIndicator(
            value: widget.userLevel.progressPercent,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.userLevel.xp} / ${widget.userLevel.xpToNextLevel} XP',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['等级', '成就', '每日任务'].map((tab) {
          final isSelected = tab == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        _buildSectionTitle('📊 数据统计'),
        const SizedBox(height: 8),
        _buildStatRow('发布动态', widget.userLevel.totalPosts, Icons.edit),
        _buildStatRow('获得点赞', widget.userLevel.totalLikes, Icons.favorite),
        _buildStatRow('发表评论', widget.userLevel.totalComments, Icons.chat_bubble),
        _buildStatRow('帮助他人', widget.userLevel.totalHelps, Icons.volunteer_activism),
        _buildStatRow('匹配成功', widget.userLevel.totalMatches, Icons.people),
        const SizedBox(height: 16),
        // Streak
        _buildSectionTitle('🔥 连续活跃'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.userLevel.streakDays} 天',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '连续活跃 ${widget.userLevel.streakDays} 天',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // How to earn XP
        _buildSectionTitle('💡 如何获得 XP'),
        const SizedBox(height: 8),
        _buildXpRule('发布动态', '+10 XP'),
        _buildXpRule('获得点赞', '+5 XP/个'),
        _buildXpRule('发表评论', '+3 XP'),
        _buildXpRule('帮助他人', '+20 XP'),
        _buildXpRule('匹配成功', '+15 XP'),
        _buildXpRule('每日登录', '+5 XP'),
        _buildXpRule('连续活跃 7 天', '+70 XP'),
      ],
    );
  }

  Widget _buildAchievementsGrid() {
    final achievements = Achievement.getAllAchievements();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return Container(
          decoration: BoxDecoration(
            color: a.isUnlocked ? Colors.purple.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: a.isUnlocked ? Colors.purple : Colors.grey[300]!,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: a.isUnlocked ? 1.0 : 0.4,
                child: Text(a.icon, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 8),
              Text(
                a.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: a.isUnlocked ? Colors.purple : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                a.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (a.isUnlocked)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+${a.xpReward} XP', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyQuests() {
    final quests = [
      {'name': '发布 1 条动态', 'icon': '📝', 'progress': 0, 'target': 1, 'xp': 10},
      {'name': '给 3 个人点赞', 'icon': '❤️', 'progress': 1, 'target': 3, 'xp': 15},
      {'name': '评论 2 条内容', 'icon': '💬', 'progress': 0, 'target': 2, 'xp': 10},
      {'name': '匹配 1 个新好友', 'icon': '🤝', 'progress': 0, 'target': 1, 'xp': 20},
      {'name': '加入 1 个语音房间', 'icon': '🎧', 'progress': 0, 'target': 1, 'xp': 15},
      {'name': '每日登录', 'icon': '📅', 'progress': 1, 'target': 1, 'xp': 5},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final q = quests[index];
        final isComplete = q['progress'] == q['target'];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(q['icon'] as String, style: const TextStyle(fontSize: 28)),
            title: Text(q['name'] as String),
            subtitle: LinearProgressIndicator(
              value: (q['progress'] as int) / (q['target'] as int),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(isComplete ? Colors.green : Colors.purple),
            ),
            trailing: isComplete
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('✅ 已完成', style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                : Text(
                    '+${q['xp']} XP',
                    style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildStatRow(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildXpRule(String action, String xp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action, style: TextStyle(color: Colors.grey[700])),
          Text(xp, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
