import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../explorer/explorer_screen.dart';
import '../map/map_screen.dart';
import '../community/community_screen.dart';
import '../manage_bookings/manage_bookings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExplorerScreen(),
    MapScreen(),
    CommunityScreen(),
    ManageBookingsScreen(),
    NotificationsScreen(),
  ];

  final List<String> _titles = const [
    'Khám phá',
    'Bản đồ',
    'Cộng đồng',
    'Quản lý',
    'Thông báo',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
              child: user?.avatarUrl == null
                  ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
          ),
        ),
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Khám phá',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Bản đồ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Cộng đồng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Quản lý',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Thông báo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
