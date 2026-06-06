import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/core/providers/service_providers.dart';


/// Splash/Auth Check Screen
/// This screen is shown while determining if user is logged in
class AuthCheckScreen extends ConsumerWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state
    final authState = ref.watch(authStateProvider);

    // Navigate based on auth state
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (context.mounted) {
          // User is logged in, navigate to home
          if (user != null) {
            context.go('/');
          } else {
            // User is not logged in, navigate to login
            context.go('/login');
          }
        }
      });

      // AsyncValue doesn't provide `whenError`; use `maybeWhen` to handle errors
      next.maybeWhen(
        error: (error, stackTrace) {
          if (context.mounted) {
            // Error occurred, show login
            context.go('/login');
          }
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/App Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.report_problem_rounded,
                size: 48,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // App Title
            Text(
              'ProblemSolvers Hub',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Problem solving community',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
              ),
            ),
            const SizedBox(height: 24),

            // Loading text
            Text(
              authState.maybeWhen(
                loading: () => 'Initializing...',
                data: (_) => 'Welcome!',
                error: (error, st) => 'An error occurred',
                orElse: () => 'Loading...',
              ),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Use `context.mounted` inside build method instead of defining `mounted` here.
}
