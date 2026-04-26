import 'package:flutter/material.dart';
import '../model/post.dart';
import '../services/post_service.dart';

/// Feed Screen for GlowStar Content Feed
/// 
/// Personalized feed based on interests + followed users
/// Supports text, image, video posts with like/comment/share
class FeedScreen extends StatefulWidget {
  final String userId;
  final PostService postService;

  const FeedScreen({
    Key? key,
    required this.userId,
    required this.postService,
  }) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  late TabController _tabController;
  String _selectedTab = '推荐';

  final List<String> _tabs = ['推荐', '关注', '附近', '学习'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _selectedTab = _tabs[_tabController.index]);
      _refreshFeed();
    });
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final posts = await widget.postService.getFeed(
        page: _currentPage,
        limit: 20,
        userId: widget.userId,
      );
      setState(() {
        if (_currentPage == 0) {
          _posts = posts;
        } else {
          _posts.addAll(posts);
        }
        _hasMore = posts.length >= 20;
        _currentPage++;
      });
    } catch (e) {
      print('Failed to load feed: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _currentPage = 0;
      _hasMore = true;
      _posts = [];
    });
    await _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发光星球'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >= notification.metrics.maxScrollExtent * 0.8) {
              _loadFeed();
            }
            return true;
          },
          child: _posts.isEmpty && !_isLoading
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _posts.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _posts.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _buildPostCard(_posts[index]);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePost,
        child: const Icon(Icons.add, size: 28),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + time
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.avatar != null
                      ? NetworkImage(post.avatar!)
                      : null,
                  child: post.avatar == null
                      ? Text(post.nickname[0], style: const TextStyle(color: Colors.white))
                      : null,
                  backgroundColor: Colors.purple,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!post.isFollowing)
                  OutlinedButton(
                    onPressed: () => _toggleFollow(post.userId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: const BorderSide(color: Colors.purple),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('关注'),
                  ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'report', child: Text('举报')),
                    const PopupMenuItem(value: 'notinterested', child: Text('不感兴趣')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Content
            Text(post.content, style: const TextStyle(fontSize: 15)),
            // Media
            if (post.mediaUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: post.type == 'image'
                    ? Image.network(post.mediaUrl!, fit: BoxFit.cover)
                    : _buildVideoPlaceholder(),
              ),
            ],
            // Tags
            if (post.tags != null && post.tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: post.tags!.map((tag) => Chip(
                  label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
            // Location
            if (post.locationName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(post.locationName!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
            const Divider(height: 20),
            // Actions: like, comment, share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionIcon(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: post.likeCount > 0 ? '${post.likeCount}' : '点赞',
                  color: post.isLiked ? Colors.red : Colors.grey,
                  onTap: () => _toggleLike(post),
                ),
                _buildActionIcon(
                  icon: Icons.chat_bubble_outline,
                  label: post.commentCount > 0 ? '${post.commentCount}' : '评论',
                  color: Colors.grey,
                  onTap: () => _showComments(post),
                ),
                _buildActionIcon(
                  icon: Icons.share,
                  label: '分享',
                  color: Colors.grey,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('还没有内容', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 8),
          Text('发布第一条动态，开始发光！', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  void _showCreatePost() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const CreatePostScreen(),
    )).then((post) {
      if (post != null) _refreshFeed();
    });
  }

  void _toggleLike(Post post) async {
    try {
      final liked = await widget.postService.toggleLike(
        postId: post.id,
        userId: widget.userId,
      );
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == post.id);
        if (idx >= 0) {
          _posts[idx] = post.copyWith(
            isLiked: liked,
            likeCount: liked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
      });
    } catch (e) {
      print('Failed to toggle like: $e');
    }
  }

  void _toggleFollow(String userId) async {
    try {
      await widget.postService.toggleFollow(
        targetUserId: userId,
        currentUserId: widget.userId,
      );
      setState(() {});
    } catch (e) {
      print('Failed to toggle follow: $e');
    }
  }

  void _showComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CommentsSheet(postId: post.id, postService: widget.postService),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}月${dt.day}日';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// Create Post Screen
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isPosting = false;

  final List<String> _popularTags = [
    '学习打卡', '数学', '英语', '物理', '音乐', '游戏',
    '运动', '读书', '电影', '美食', '旅行', '绘画',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发动态'),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('发布', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '分享你的想法...',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _popularTags.map((tag) => ChoiceChip(
                label: Text('#$tag'),
                selected: _selectedTags.contains(tag),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (_selectedTags.length < 5) _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              )).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPostAction(Icons.image, '图片'),
                _buildPostAction(Icons.videocam, '视频'),
                _buildPostAction(Icons.location_on, '位置'),
                _buildPostAction(Icons.tag, '标签'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _submitPost() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    // In real implementation, call postService.createPost()
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pop(context, true);
  }
}

/// Comments Bottom Sheet
class _CommentsSheet extends StatefulWidget {
  final String postId;
  final PostService postService;
  const _CommentsSheet({Key? key, required this.postId, required this.postService}) : super(key: key);
  @override
  _CommentsSheetState createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _comments = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('评论', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))],
            ),
          ),
          Expanded(
            child: _comments.isEmpty
                ? const Center(child: Text('暂无评论，来抢沙发吧！', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          child: Text((c['nickname'] ?? '?')[0], style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.purple,
                        ),
                        title: Text(c['nickname'] ?? '用户', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        subtitle: Text(c['content'] ?? '', style: const TextStyle(fontSize: 14)),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '说点什么...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purple),
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;
                    // In real implementation, call postService.addComment()
                    setState(() {
                      _comments.add({
                        'nickname': '我',
                        'content': _controller.text.trim(),
                      });
                    });
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
