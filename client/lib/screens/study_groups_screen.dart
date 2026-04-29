import 'package:flutter/material.dart';

/// Study Groups Screen for GlowStar
/// 
/// Allows users to create, join, and manage study groups
class StudyGroupsScreen extends StatefulWidget {
  @override
  _StudyGroupsScreenState createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final List<Map<String, dynamic>> _myGroups = [
    {
      'id': 'group1',
      'name': '数学学习小组',
      'subject': 'Math',
      'members': 5,
      'maxMembers': 10,
      'avatar': 'https://example.com/group1.jpg',
      'lastMessage': '小明：这道题怎么做？',
      'time': '5 分钟前',
      'isOnline': true,
    },
    {
      'id': 'group2',
      'name': '物理讨论组',
      'subject': 'Physics',
      'members': 3,
      'maxMembers': 8,
      'avatar': 'https://example.com/group2.jpg',
      'lastMessage': '小红：实验报告写完了吗？',
      'time': '15 分钟前',
      'isOnline': true,
    },
  ];

  final List<Map<String, dynamic>> _availableGroups = [
    {
      'id': 'group3',
      'name': '英语角',
      'subject': 'English',
      'members': 8,
      'maxMembers': 15,
      'avatar': 'https://example.com/group3.jpg',
      'description': '每天练习英语口语，互相纠正发音',
      'distance': '2.5 km',
    },
    {
      'id': 'group4',
      'name': '化学实验小组',
      'subject': 'Chemistry',
      'members': 4,
      'maxMembers': 10,
      'avatar': 'https://example.com/group4.jpg',
      'description': '一起讨论化学实验，分享实验心得',
      'distance': '3.2 km',
    },
  ];

  String _selectedTab = '我的小组';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('学习小组'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewGroup,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == '我的小组'
                ? _buildMyGroupsList()
                : _buildAvailableGroupsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem('我的小组', _selectedTab == '我的小组'),
          _buildTabItem('发现小组', _selectedTab == '发现小组'),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyGroupsList() {
    if (_myGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('暂无学习小组', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _createNewGroup,
              child: Text('创建学习小组'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _myGroups.length,
      itemBuilder: (context, index) {
        return _buildGroupCard(_myGroups[index], isMyGroup: true);
      },
    );
  }

  Widget _buildAvailableGroupsList() {
    if (_availableGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('暂无可用小组', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _availableGroups.length,
      itemBuilder: (context, index) {
        return _buildGroupCard(_availableGroups[index], isMyGroup: false);
      },
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, {required bool isMyGroup}) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(group['avatar']),
          radius: 24,
        ),
        title: Text(
          group['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (isMyGroup)
              Text(group['lastMessage'] ?? '', style: TextStyle(fontSize: 12))
            else
              Text(group['description'] ?? '', style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${group['members']}/${group['maxMembers']} 人',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  isMyGroup ? (group['time'] ?? '') : (group['distance'] ?? ''),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: isMyGroup
            ? Icon(Icons.arrow_forward_ios, size: 16)
            : ElevatedButton(
                onPressed: () => _joinGroup(group),
                child: Text('加入'),
              ),
        onTap: isMyGroup ? () => _openGroupChat(group) : null,
      ),
    );
  }

  void _createNewGroup() {
    // Navigate to create group screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('创建学习小组'),
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

  void _joinGroup(Map<String, dynamic> group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('加入小组'),
        content: Text('确定要加入"${group['name']}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已加入"${group['name']}"')),
              );
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _openGroupChat(Map<String, dynamic> group) {
    // Navigate to group chat screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('小组聊天'),
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
}
