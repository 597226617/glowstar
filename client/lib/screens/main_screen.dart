import 'package:flutter/material.dart';
import 'package:hood/screens/news_screen.dart';
import 'package:hood/screens/profile_screen.dart';
import 'package:hood/screens/interest_selection_screen.dart';

import 'conversations_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  static List<Widget> _widgetOptions = <Widget>[
    NewsForm(),
    ConversationsForm(),
    InterestSelectionScreen(),
    ProfileForm()
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("GlowStar"),
        )
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: _widgetOptions.elementAt(_selectedIndex),
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            title: Text('News'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Messages'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text('Interests'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
