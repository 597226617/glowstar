import 'package:flutter/material.dart';
import '../model/post.dart';
import '../services/post_service.dart';

/// Feed Screen for GlowStar Content Feed
///
/// Personalized feed based on interests + followed users
/// Supports text, image, video posts with like/comment/share
class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  late TabController _tabController;
  String _selectedTab = '推荐';

  final List<String> _tabs = ['推荐', '关注', '附近', '学习'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabs[_tabController.index];
        });
      }
    });
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    // Simulate loading - replace with real API call
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _posts = [
        {
          'id': '1',
          'author': '学霸小明',
          'avatar': '🧑‍🎓',
          'content': '分享一个超有用的数学公式记忆技巧！',
          'images': [],
          'likes': 42,
          'comments': 8,
          'time': '10分钟前',
          'tags': ['学习', '数学'],
        },
        {
          'id': '2',
          'author': '音乐达人',
          'avatar': '🎵',
          'content': '今晚语音房聊吉他，有兴趣的同学来玩！🎸',
          'images': [],
          'likes': 28,
          'comments': 15,
          'time': '30分钟前',
          'tags': ['音乐', '语音房'],
        },
        {
          'id': '3',
          'author': '深夜食堂',
          'avatar': '🌙',
          'content': '有人想一起组队学编程吗？Python入门那种~',
          'images': [],
          'likes': 56,
          'comments': 23,
          'time': '1小时前',
          'tags': ['编程', '组队'],
        },
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF9C27B0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF9C27B0),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _PostCard(post: post);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(post['avatar'] ?? '👤')),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['author'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(post['time'], style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_horiz, size: 18), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 10),
            Text(post['content'], style: const TextStyle(fontSize: 15)),
            if ((post['tags'] as List?)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  children: (post['tags'] as List).map((t) =>
                    Chip(label: Text(t, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ).toList(),
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                _ActionButton(icon: Icons.favorite_border, label: '${post['likes']}', onTap: () {}),
                const SizedBox(width: 24),
                _ActionButton(icon: Icons.chat_bubble_outline, label: '${post['comments']}', onTap: () {}),
                const SizedBox(width: 24),
                _ActionButton(icon: Icons.share_outlined, label: '分享', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
