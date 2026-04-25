import 'package:flutter/material.dart';

/// Settings Screen for GlowStar
/// 
/// User settings, preferences, and account management
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _showOnlineStatus = true;
  double _maxDistance = 50.0;
  String _language = 'zh-CN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSection('账户'),
          _buildSettingItem(Icons.person, '个人资料', () {}),
          _buildSettingItem(Icons.security, '隐私设置', () {}),
          _buildSettingItem(Icons.notifications, '通知设置', () {}),
          SizedBox(height: 16),
          _buildSection('显示'),
          _buildSwitchItem('深色模式', _darkMode, (value) {
            setState(() {
              _darkMode = value;
            });
          }),
          _buildSettingItem(Icons.language, '语言', () {}, subtitle: _language),
          _buildSettingItem(Icons.palette, '主题颜色', () {}),
          SizedBox(height: 16),
          _buildSection('隐私'),
          _buildSwitchItem('显示在线状态', _showOnlineStatus, (value) {
            setState(() {
              _showOnlineStatus = value;
            });
          }),
          _buildSwitchItem('允许位置访问', _locationEnabled, (value) {
            setState(() {
              _locationEnabled = value;
            });
          }),
          _buildSliderItem('最大距离', _maxDistance, 5.0, 100.0, (value) {
            setState(() {
              _maxDistance = value;
            });
          }),
          SizedBox(height: 16),
          _buildSection('帮助'),
          _buildSettingItem(Icons.help, '帮助中心', () {}),
          _buildSettingItem(Icons.feedback, '意见反馈', () {}),
          _buildSettingItem(Icons.info, '关于我们', () {}),
          SizedBox(height: 16),
          _buildSection('账户管理'),
          _buildSettingItem(Icons.logout, '退出登录', () {}, isDestructive: true),
          _buildSettingItem(Icons.delete, '删除账户', () {}, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap, {String? subtitle, bool isDestructive = false}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : null)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSliderItem(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: 20,
                    label: '${value.toStringAsFixed(0)}km',
                    onChanged: onChanged,
                  ),
                ),
                Text('${value.toStringAsFixed(0)}km'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
