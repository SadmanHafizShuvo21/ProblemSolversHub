import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/auth_page.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/login_screen_new.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/signup_screen_new.dart';
import 'package:problem_solvers_hub/ui/app.dart';
import 'package:problem_solvers_hub/ui/screens/create_post_screen.dart';
import 'package:problem_solvers_hub/ui/screens/explore_screen.dart';
import 'package:problem_solvers_hub/ui/screens/feed_screen.dart';
import 'package:problem_solvers_hub/ui/screens/friends_screen.dart';
import 'package:problem_solvers_hub/ui/screens/profile_screen.dart';

/// Application Router Configuration
class AppRouter {
  static GoRouter createRouter(Ref ref) {
    final authState = ref.watch(authProvider);

    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAuthenticated = authState.maybeWhen(
          data: (user) => user != null,
          orElse: () => false,
        );

        final path = state.uri.path;
        final loggingIn = path == '/login';
        final signingUp = path == '/signup';
        final authLanding = path == '/auth';
        final profileRoute = path == '/profile';

        if (!isAuthenticated && profileRoute) {
          return '/auth';
        }

        if (isAuthenticated && (loggingIn || signingUp || authLanding)) {
          return '/profile';
        }

        return null;
      },
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
          ],
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
      ],
    );
  }
}

/// Riverpod provider for the GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
