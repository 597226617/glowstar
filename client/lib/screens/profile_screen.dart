import 'package:flutter/material.dart';

/// Profile Screen for GlowStar
/// 
/// Shows user profile with interest tags, level, stats
class ProfileForm extends StatefulWidget {
  final String? userId;
  final String? nickname;
  final String? avatar;

  const ProfileForm({
    Key? key,
    this.userId,
    this.nickname,
    this.avatar,
  }) : super(key: key);

  @override
  ProfileFormState createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Demo data
  final String _nickname = '发光星人';
  final int _level = 5;
  final int _xp = 2400;
  final int _xpToNext = 3000;
  
  final List<Map<String, String>> _interests = [
    {'name': '🎵 流行音乐', 'category': '音乐'},
    {'name': '🏀 篮球', 'category': '运动'},
    {'name': '📖 英语', 'category': '学习'},
    {'name': '📚 小说', 'category': '阅读'},
    {'name': '☕ 咖啡', 'category': '美食'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildProfileHeader(),
          ];
        },
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(),
                  _buildInterestsTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF9C27B0),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A3E), Color(0xFF9C27B0)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.amber],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.star, size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nickname
                  Text(
                    _nickname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bio
                  const Text(
                    '让相同兴趣的人，在地图上一起发光 ✨',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // Level and XP bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Lv.$_level',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _xp / _xpToNext,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_xp/$_xpToNext',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Interest tags (horizontal scroll)
                  SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _interests.map((interest) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            interest['name']!,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF9C27B0),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF9C27B0),
        tabs: const [
          Tab(text: '动态'),
          Tab(text: '兴趣'),
          Tab(text: '成就'),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildStatRow(),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(Icons.article_outlined, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('还没有动态', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              const SizedBox(height: 4),
              Text('发布第一条动态，开始发光！', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('12', '关注'),
        _buildStatItem('28', '粉丝'),
        _buildStatItem('156', '获赞'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInterestsTab() {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: _interests.map((interest) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9C27B0).withOpacity(0.1),
                const Color(0xFF9C27B0).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              interest['name']!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9C27B0)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAchievementCard('🌟', '真诚之星', '获得 10 次真诚评价', true),
        _buildAchievementCard('📚', '学霸助手', '帮助 5 位同学', true),
        _buildAchievementCard('🔥', '连续打卡', '连续 7 天活跃', true),
        _buildAchievementCard('💬', '社交达人', '发起 20 次真诚对话', false),
        _buildAchievementCard('🗺️', '探索者', '参加 5 次线下活动', false),
        _buildAchievementCard('⭐', '发光行星', '达到 Lv.10', false),
      ],
    );
  }

  Widget _buildAchievementCard(String icon, String title, String desc, bool unlocked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: unlocked ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? const Color(0xFF9C27B0).withOpacity(0.15) : Colors.grey[200],
          ),
          child: Center(
            child: Text(icon, style: TextStyle(fontSize: 22, color: unlocked ? null : Colors.grey)),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: unlocked ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: Color(0xFF9C27B0))
            : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }
}
