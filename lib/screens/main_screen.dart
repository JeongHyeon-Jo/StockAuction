import 'package:auction/config/color.dart';
import 'package:auction/screens/my/my_screen.dart';
import 'package:auction/screens/post/post_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat/chat_list_screen.dart';
import 'home/home_screen.dart';
import 'like/my_likes_screen.dart';
import 'package:auction/providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  late int pageIndex;

  MainScreen({super.key, this.pageIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.pageIndex;
  }

  final List<Widget> _pages = [
    HomeScreen(),
    PostListScreen(),
    ChatListScreen(),
    MyLikesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Stock Auction',
          style: TextStyle(
            color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
        themeProvider.isDarkTheme ? Colors.black : Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person,
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor:
        themeProvider.isDarkTheme ? Colors.white : AppsColor.pastelGreen,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor:
        themeProvider.isDarkTheme ? Colors.black : Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: '경매'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '찜 목록'),
        ],
      ),
    );
  }
}