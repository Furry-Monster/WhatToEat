import 'package:flutter/material.dart';
import 'package:witch_one/screens/food_database_screen.dart';
import 'package:witch_one/screens/home_screen.dart';
import 'package:witch_one/screens/history_screen.dart';
import 'package:witch_one/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FoodDatabaseScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        height: 60,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 28),
            selectedIcon: Icon(Icons.home, size: 28),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined, size: 28),
            selectedIcon: Icon(Icons.restaurant_menu, size: 28),
            label: '数据库',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, size: 28),
            selectedIcon: Icon(Icons.history, size: 28),
            label: '历史',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 28),
            selectedIcon: Icon(Icons.settings, size: 28),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
