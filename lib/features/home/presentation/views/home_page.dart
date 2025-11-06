import 'package:flutter/material.dart';
import 'package:med_just/features/news/presentation/screens/news_list_screen.dart';
import 'package:med_just/features/profile/presentation/screens/profile_screen.dart';
import 'package:med_just/features/resourses/presentation/screens/years_page.dart';
import 'package:med_just/features/sidebar/presentation/screens/sidebar_screen.dart';
import 'package:med_just/features/store/presentation/screens/store_screen.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/themes/app_colors.dart';
import '../widgets/home_widgets.dart';
import '../controller/home_bloc.dart';
import '../controller/home_event.dart';
import '../controller/home_state.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc _homeBloc = HomeBloc();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    YearsPage(),
    NewsListScreen(),
    StoreScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    'Resources',
    'Latest News',
    'Med Store',
    'Profile',
  ];

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          Image.asset('assets/images/logo_outline_full.png', height: 32),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: SideMenu(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'person':
        return Icons.person;
      case 'article':
        return Icons.article;
      case 'store':
        return Icons.store;
      case 'calculate':
        return Icons.calculate;
      case 'map':
        return Icons.map;
      default:
        return Icons.dashboard;
    }
  }
}
