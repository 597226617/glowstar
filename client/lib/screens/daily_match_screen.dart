import 'package:flutter/material.dart';
import 'package:glowstar/model/interest_tag.dart';
import 'package:glowstar/services/matching_service.dart';

/// Daily Match Screen for GlowStar
/// 
/// Shows top 10 daily recommended matches (quality over quantity)
/// Each card shows: interests, match reason, distance, match score
class DailyMatchScreen extends StatefulWidget {
  final String userId;
  final MatchingService matchingService;

  const DailyMatchScreen({
    Key? key,
    required this.userId,
    required this.matchingService,
  }) : super(key: key);

  @override
  _DailyMatchScreenState createState() => _DailyMatchScreenState();
}

class _DailyMatchScreenState extends State<DailyMatchScreen> {
  List<MatchResult> _matches = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyMatches();
  }

  Future<void> _loadDailyMatches() async {
    final matches = await widget.matchingService.getDailyMatches(
      userId: widget.userId,
      latitude: 39.9042,
      longitude: 116.4074,
    );
    
    if (matches.isEmpty) {
      // Demo data for development
      matches.addAll(_generateDemoMatches());
    }
    
    setState(() {
      _matches = matches;
      _isLoading = false;
    });
  }

  List<MatchResult> _generateDemoMatches() {
    return [
      MatchResult(
        id: 'match1',
        nickname: '小雨',
        bio: '学渣求学霸带飞 🙏 喜欢音乐和读书',
        isOnline: true,
        distance: 600,
        interests: [
          InterestTag(id: 'study_math', name: '数学', category: '学习', icon: '📐'),
          InterestTag(id: 'study_english', name: '英语', category: '学习', icon: '📖'),
          InterestTag(id: 'music_pop', name: '流行音乐', category: '音乐', icon: '🎵'),
        ],
        sharedInterestCount: 2,
        matchScore: 0.85,
        matchReason: '你们都喜欢数学、英语！',
      ),
      MatchResult(
        id: 'match2',
        nickname: '小明',
        bio: '喜欢摇滚和篮球的阳光男孩 🤘',
        isOnline: true,
        distance: 1200,
        interests: [
          InterestTag(id: 'music_rock', name: '摇滚', category: '音乐', icon: '🎸'),
          InterestTag(id: 'sports_basketball', name: '篮球', category: '运动', icon: '🏀'),
        ],
        sharedInterestCount: 1,
        matchScore: 0.72,
        matchReason: '你们都喜欢音乐！',
      ),
      MatchResult(
        id: 'match3',
        nickname: '阿杰',
        bio: '编程爱好者，一起写代码？',
        isOnline: true,
        distance: 2000,
        interests: [
          InterestTag(id: 'tech_programming', name: '编程', category: '科技', icon: '⌨️'),
          InterestTag(id: 'gaming_pc', name: 'PC游戏', category: '游戏', icon: '🖥️'),
          InterestTag(id: 'food_coffee', name: '咖啡', category: '美食', icon: '☕'),
        ],
        sharedInterestCount: 0,
        matchScore: 0.45,
        matchReason: '就在你附近～',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日推荐 ✨'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _loadDailyMatches,
            child: const Text('刷新', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${_currentIndex + 1}/${_matches.length}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (_currentIndex + 1) / _matches.length,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Match card
                    Expanded(
                      child: _matches.isEmpty || _currentIndex >= _matches.length
                          ? _buildEmptyState()
                          : _buildMatchCard(_matches[_currentIndex]),
                    ),
                    // Action buttons
                    if (_matches.isNotEmpty && _currentIndex < _matches.length)
                      _buildActionButtons(),
                  ],
                ),
    );
  }

  Widget _buildMatchCard(MatchResult match) {
    final primaryColor = Color(
      match.interests.isNotEmpty 
          ? InterestColors.getColorForTag(match.interests.first)
          : 0xFF9C27B0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match score badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '匹配度 ${(match.matchScore * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Avatar and basic info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryColor.withOpacity(0.3),
                      child: Text(
                        match.nickname[0],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match.nickname,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        if (match.isOnline)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${match.distanceText} · ${match.isOnline ? "在线" : "离线"}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              
              // Match reason (highlighted)
              if (match.matchReason.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.2)),
                  ),
                  child: Text(
                    match.matchReason,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              
              // Bio
              if (match.bio != null && match.bio!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  match.bio!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
              
              // Interest tags
              const SizedBox(height: 14),
              const Text(
                'TA的兴趣',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: match.interests.map((interest) {
                  final tagColor = Color(InterestColors.getColor(interest.category));
                  final isShared = match.sharedInterestCount > 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(isShared ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: tagColor.withOpacity(isShared ? 0.5 : 0.2),
                      ),
                    ),
                    child: Text(
                      '${interest.icon} ${interest.name}',
                      style: TextStyle(
                        color: tagColor,
                        fontSize: 13,
                        fontWeight: isShared ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              // Shared interests count
              if (match.sharedInterestCount > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.purple, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${match.sharedInterestCount} 个共同兴趣',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Skip
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _skipToNext,
              icon: const Icon(Icons.close),
              label: const Text('下一个'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Say hi
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _sayHi(_matches[_currentIndex]),
              icon: const Icon(Icons.chat_bubble),
              label: const Text('打招呼 ✨'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 80, color: Colors.purple),
          const SizedBox(height: 16),
          const Text(
            '今日推荐已看完',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '明天会推荐新的同好，保持发光！✨',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadDailyMatches,
            child: const Text('重新推荐'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _skipToNext() {
    setState(() {
      if (_currentIndex < _matches.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _sayHi(MatchResult match) {
    Navigator.of(context).pushNamed('/chat', arguments: {
      'userId': widget.userId,
      'targetUserId': match.id,
      'targetNickname': match.nickname,
      'matchReason': match.matchReason,
    });
  }
}
