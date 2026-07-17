import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../explorer/explorer_screen.dart';
import '../map/map_screen.dart';
import '../community/community_screen.dart';
import '../manage_bookings/manage_bookings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../favorites/favorites_screen.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../auth/login_screen.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      void checkAndLoad() {
        if (authProvider.currentUser != null) {
          Provider.of<FavoriteProvider>(context, listen: false)
              .loadFavorites(authProvider.currentUser!.id!);
          Provider.of<NotificationProvider>(context, listen: false)
              .loadNotifications(authProvider.currentUser!.id!);
          authProvider.removeListener(checkAndLoad);
        }
      }

      if (authProvider.currentUser != null) {
        checkAndLoad();
      } else {
        authProvider.addListener(checkAndLoad);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              GestureDetector(
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  if (user != null) {
                    await authProvider.logout();
                  }
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: Icon(
                  user != null ? Icons.logout : Icons.login,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Khám phá',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Bản đồ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Cộng đồng',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Quản lý',
              ),
              BottomNavigationBarItem(
                icon: Consumer<NotificationProvider>(
                  builder: (context, notif, child) {
                    if (notif.unreadCount > 0) {
                      return Badge(
                        label: Text('${notif.unreadCount}'),
                        child: const Icon(Icons.notifications_none_outlined),
                      );
                    }
                    return const Icon(Icons.notifications_none_outlined);
                  },
                ),
                activeIcon: Consumer<NotificationProvider>(
                  builder: (context, notif, child) {
                    if (notif.unreadCount > 0) {
                      return Badge(
                        label: Text('${notif.unreadCount}'),
                        child: const Icon(Icons.notifications),
                      );
                    }
                    return const Icon(Icons.notifications);
                  },
                ),
                label: 'Thông báo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
