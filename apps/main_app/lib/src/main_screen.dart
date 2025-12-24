import 'package:flutter/material.dart';
import 'package:main_app/src/home_tab.dart';
import 'package:main_app/src/user_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<HomeTabState> _homeKey = GlobalKey<HomeTabState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeTab(key: _homeKey,),
      const UserTab()
    ];
  }

  void _onItemTapped(int index) {
    // Nếu bấm vào tab Home (index 0) VÀ đang ở tab Home rồi
    if (index == 0 && _currentIndex == 0) {
      print("Reloading Home Tab...");
      // Gọi hàm refresh() bên trong HomeTab
      _homeKey.currentState?.refresh();
    } 
    
    // Chuyển tab bình thường
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
        ],
      ),
    );
  }
}
