import 'package:flutter/material.dart';

/// Privacy Settings Screen for GlowStar
/// 
/// Allows users to control their privacy settings
class PrivacySettingsScreen extends StatefulWidget {
  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _showOnlineStatus = true;
  bool _showLocation = true;
  bool _showAge = true;
  bool _showInterests = true;
  bool _allowDirectMessages = true;
  bool _allowGroupInvites = true;
  bool _showInSearch = true;
  bool _dataSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('隐私设置'),
      ),
      body: ListView(
        children: [
          _buildSection('可见性'),
          _buildSwitchItem('显示在线状态', _showOnlineStatus, (value) {
            setState(() {
              _showOnlineStatus = value;
            });
          }),
          _buildSwitchItem('显示位置', _showLocation, (value) {
            setState(() {
              _showLocation = value;
            });
          }),
          _buildSwitchItem('显示年龄', _showAge, (value) {
            setState(() {
              _showAge = value;
            });
          }),
          _buildSwitchItem('显示兴趣爱好', _showInterests, (value) {
            setState(() {
              _showInterests = value;
            });
          }),
          _buildSwitchItem('在搜索中显示', _showInSearch, (value) {
            setState(() {
              _showInSearch = value;
            });
          }),
          SizedBox(height: 16),
          _buildSection('互动'),
          _buildSwitchItem('允许私信', _allowDirectMessages, (value) {
            setState(() {
              _allowDirectMessages = value;
            });
          }),
          _buildSwitchItem('允许小组邀请', _allowGroupInvites, (value) {
            setState(() {
              _allowGroupInvites = value;
            });
          }),
          SizedBox(height: 16),
          _buildSection('数据'),
          _buildSwitchItem('数据共享（用于改进服务）', _dataSharing, (value) {
            setState(() {
              _dataSharing = value;
            });
          }),
          SizedBox(height: 16),
          _buildSection('账户安全'),
          _buildSettingItem(Icons.lock, '修改密码', () {}),
          _buildSettingItem(Icons.security, '两步验证', () {}),
          _buildSettingItem(Icons.history, '登录历史', () {}),
          SizedBox(height: 16),
          _buildSection('已屏蔽的用户'),
          _buildSettingItem(Icons.block, '管理屏蔽列表', () {}),
          SizedBox(height: 16),
          _buildSection('法律'),
          _buildSettingItem(Icons.description, '隐私政策', () {}),
          _buildSettingItem(Icons.gavel, '服务条款', () {}),
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

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
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
}
