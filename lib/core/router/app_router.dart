import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/auth_page.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/login_screen_new.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/signup_screen_new.dart';
import 'package:problem_solvers_hub/features/post/screens/post_detail_screen.dart';
import 'package:problem_solvers_hub/shared/models/post.dart';
import 'package:problem_solvers_hub/ui/app.dart';
import 'package:problem_solvers_hub/ui/screens/activity_detail_screen.dart';
import 'package:problem_solvers_hub/ui/screens/create_post_screen.dart';
import 'package:problem_solvers_hub/ui/screens/explore_screen.dart';
import 'package:problem_solvers_hub/ui/screens/feed_screen.dart';
import 'package:problem_solvers_hub/ui/screens/friends_screen.dart';
import 'package:problem_solvers_hub/ui/screens/profile_screen.dart';
import 'package:problem_solvers_hub/ui/screens/profile_settings_screen.dart';

/// Single stable GoRouter instance - kept as a global to prevent recreation
late final GoRouter _stableRouter;

/// Application Router Configuration
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: 'feed',
              builder: (context, state) => const FeedScreen(),
            ),
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) => const ExploreScreen(),
            ),
            GoRoute(
              path: '/create',
              name: 'create',
              builder: (context, state) => const CreatePostScreen(),
            ),
            GoRoute(
              path: '/friends',
              name: 'friends',
              builder: (context, state) => const FriendsScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/profile/settings',
              name: 'profile-settings',
              builder: (context, state) => const ProfileSettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/activity',
          name: 'activity',
          builder: (context, state) {
            final data = state.extra;
            return ActivityDetailScreen(
              activityData: data is Map<String, dynamic> ? data : <String, dynamic>{},
            );
          },
        ),
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/post',
          name: 'post-detail',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Post) {
              return PostDetailScreen(post: extra);
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Post detail')),
              body: Center(
                child: Text(
                  'Unable to open post details. Please return and try again.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Page Not Found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Riverpod provider for stable GoRouter that doesn't recreate
final goRouterProvider = Provider<GoRouter>((ref) {
  // Create the router once and return the same instance
  _stableRouter = AppRouter.createRouter();
  return _stableRouter;
});
