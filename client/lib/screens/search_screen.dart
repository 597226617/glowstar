import 'package:flutter/material.dart';

/// Search Screen for GlowStar
/// 
/// Search for users, groups, and study materials
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _recentSearches = [
    {'type': 'user', 'name': '小明', 'avatar': 'https://example.com/avatar1.jpg'},
    {'type': 'group', 'name': '数学学习小组', 'members': 5},
    {'type': 'user', 'name': '小红', 'avatar': 'https://example.com/avatar2.jpg'},
  ];

  final List<Map<String, dynamic>> _suggestions = [
    {'type': 'topic', 'title': '数学', 'icon': '📐'},
    {'type': 'topic', 'title': '物理', 'icon': '⚡'},
    {'type': 'topic', 'title': '化学', 'icon': '🧪'},
    {'type': 'topic', 'title': '英语', 'icon': '🌍'},
    {'type': 'topic', 'title': '历史', 'icon': '📜'},
    {'type': 'topic', 'title': '地理', 'icon': '🗺️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索用户、小组、学科...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) => _performSearch(value),
          onSubmitted: (value) => _performSearch(value),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? _buildSuggestionsScreen()
          : _isSearching
              ? Center(child: CircularProgressIndicator())
              : _buildSearchResults(),
    );
  }

  Widget _buildSuggestionsScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近搜索', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ..._recentSearches.map((search) => _buildRecentSearchItem(search)),
          SizedBox(height: 24),
          Text('热门学科', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) => ElevatedButton.icon(
              onPressed: () => _searchController.text = suggestion['title'],
              icon: Text(suggestion['icon'], style: TextStyle(fontSize: 20)),
              label: Text(suggestion['title']),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(Map<String, dynamic> search) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(search['avatar'] ?? ''),
          child: search['type'] == 'group' ? Icon(Icons.groups) : null,
        ),
        title: Text(search['name']),
        subtitle: search['type'] == 'group'
            ? Text('${search['members']} 人')
            : Text('用户'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _searchController.text = search['name'],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('暂无搜索结果', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> result) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(result['avatar'] ?? ''),
          child: result['type'] == 'group' ? Icon(Icons.groups) : null,
        ),
        title: Text(result['name']),
        subtitle: result['type'] == 'group'
            ? Text('${result['members']} 人')
            : Text('用户 · ${result['matchScore']}% 匹配'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _openResult(result),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
        // Add mock results
        _searchResults.addAll([
          {
            'type': 'user',
            'name': '数学学霸',
            'avatar': 'https://example.com/avatar3.jpg',
            'matchScore': 95,
          },
          {
            'type': 'group',
            'name': '数学学习小组',
            'members': 5,
          },
        ]);
      });
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
    });
  }

  void _openResult(Map<String, dynamic> result) {
    // Navigate to result detail
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['name']),
        content: Text('功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
