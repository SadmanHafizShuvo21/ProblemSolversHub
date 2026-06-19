import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/core/router/app_router.dart';
import 'package:problem_solvers_hub/core/theme/app_theme.dart';
import 'package:problem_solvers_hub/features/auth/presentation/providers/auth_providers.dart';

class ProblemSolversHubApp extends ConsumerWidget {
  const ProblemSolversHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Listen to auth state changes for initial route navigation
    ref.listen<AsyncValue<dynamic>>(authProvider, (previous, next) {
      next.whenData((user) {
        if (context.mounted && goRouter.routerDelegate.currentConfiguration.isNotEmpty) {
          final currentPath = GoRouterState.of(context).uri.path;
          
          if (user != null) {
            // User is logged in
            debugPrint('✅ Auth state listener: User logged in - $currentPath');
            if (currentPath == '/login' || currentPath == '/signup' || currentPath == '/auth') {
              debugPrint('✅ Redirecting from auth page to /');
              Future.microtask(() {
                if (context.mounted) {
                  goRouter.go('/');
                }
              });
            }
          } else {
            // User is logged out
            debugPrint('✅ Auth state listener: User logged out - $currentPath');
            if (currentPath.startsWith('/') && currentPath != '/login' && currentPath != '/signup' && currentPath != '/auth' && currentPath != '/forgot-password') {
              debugPrint('✅ Redirecting from protected route to /auth');
              Future.microtask(() {
                if (context.mounted) {
                  goRouter.go('/auth');
                }
              });
            }
          }
        }
      });
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ProblemSolvers Hub',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/create')) return 2;
    if (location.startsWith('/friends')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/explore');
              break;
            case 2:
              context.go('/create');
              break;
            case 3:
              context.go('/friends');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


