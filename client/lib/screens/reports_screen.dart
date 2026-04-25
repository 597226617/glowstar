import 'package:flutter/material.dart';

/// Reports Screen for GlowStar
/// 
/// Shows user's activity reports and statistics
class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final Map<String, dynamic> _weeklyReport = {
    'matches': 12,
    'messages': 45,
    'groupsJoined': 2,
    'studySessions': 8,
    'aiAssistance': 15,
    'loginDays': 6,
  };

  final Map<String, dynamic> _monthlyReport = {
    'matches': 48,
    'messages': 180,
    'groupsJoined': 5,
    'studySessions': 32,
    'aiAssistance': 60,
    'loginDays': 25,
  };

  String _selectedPeriod = 'weekly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('活动报告'),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('匹配统计'),
                  _buildStatCard('匹配数', _getReportData('matches').toString(), Icons.favorite),
                  _buildStatCard('消息数', _getReportData('messages').toString(), Icons.message),
                  SizedBox(height: 16),
                  _buildSection('学习统计'),
                  _buildStatCard('加入小组', _getReportData('groupsJoined').toString(), Icons.groups),
                  _buildStatCard('学习 session', _getReportData('studySessions').toString(), Icons.school),
                  _buildStatCard('AI 帮助', _getReportData('aiAssistance').toString(), Icons.smart_toy),
                  SizedBox(height: 16),
                  _buildSection('活跃度'),
                  _buildStatCard('登录天数', _getReportData('loginDays').toString(), Icons.calendar_today),
                  SizedBox(height: 24),
                  _buildAchievements(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodButton('本周', 'weekly'),
          SizedBox(width: 8),
          _buildPeriodButton('本月', 'monthly'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    bool isSelected = _selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('成就', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAchievementChip('🌟 初次匹配', _getReportData('matches') >= 1),
            _buildAchievementChip('💬 社交达人', _getReportData('messages') >= 10),
            _buildAchievementChip('📚 学习之星', _getReportData('studySessions') >= 5),
            _buildAchievementChip('🤖 AI 助手', _getReportData('aiAssistance') >= 10),
            _buildAchievementChip('🔥 连续登录', _getReportData('loginDays') >= 7),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementChip(String label, bool unlocked) {
    return Chip(
      label: Text(label),
      backgroundColor: unlocked ? Colors.green[100] : Colors.grey[200],
      labelStyle: TextStyle(
        color: unlocked ? Colors.green[900] : Colors.grey[600],
      ),
    );
  }

  dynamic _getReportData(String key) {
    if (_selectedPeriod == 'weekly') {
      return _weeklyReport[key];
    }
    return _monthlyReport[key];
  }
}
