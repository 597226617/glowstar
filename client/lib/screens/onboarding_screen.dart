import 'package:flutter/material.dart';

/// Onboarding Screen for GlowStar
/// 
/// Guides new users through app setup and feature introduction
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '欢迎使用发光星球',
      description: '让相同兴趣的人，在地图上一起发光',
      icon: Icons.star,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: '发现附近的人',
      description: '通过地图发现附近的同好和学友',
      icon: Icons.map,
      color: Colors.green,
    ),
    OnboardingPage(
      title: '兴趣匹配',
      description: '通过共同兴趣找到志同道合的朋友',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    OnboardingPage(
      title: '学习帮扶',
      description: '连接想学习的初高中学生，共同进步',
      icon: Icons.school,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: '开始探索',
      description: '选择你的兴趣，开始发光之旅！',
      icon: Icons.rocket_launch,
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[_currentPage].color.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildNavigation(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 100,
            color: page.color,
          ),
          SizedBox(height: 40),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            child: Text('上一页'),
          ),
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? _pages[index].color
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage < _pages.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () {
                    // Navigate to main screen
                    Navigator.of(context).pushReplacementNamed('/main');
                  },
            child: Text(_currentPage < _pages.length - 1 ? '下一页' : '开始'),
          ),
        ],
      ),
    );
  }
}

/// Onboarding Page model
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
