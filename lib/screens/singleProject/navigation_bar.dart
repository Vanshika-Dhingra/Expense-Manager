import 'package:flutter/material.dart';

import '../home.dart';
import '../project/project_screen.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({Key? key}) : super(key: key);

  @override
  AppBottomNavigationBarState createState() => AppBottomNavigationBarState();
}

class AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
   int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Perform different actions based on the selected tab
    switch (index) {
      case 0:
        _handleHomeTab();
        break;
      case 1:
        _handleExploreTab();
        break;
      case 2:
        _handleProfileTab();
        break;
      default:
      // Handle any other tab index if needed
    }
  }

  void _handleHomeTab() {
    //Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    ));
  }

  void _handleExploreTab() {
    //Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const ProjectScreen(),
    ));
  }

  void _handleProfileTab() {
    // Perform actions for the profile tab
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.white),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore, color: Colors.white),
          label: 'Projects',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.white),
          label: 'Profile',
        ),
      ],
    );
  }
}
