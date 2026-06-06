import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/domain/entities/user.dart';
import 'package:problem_solvers_hub/features/auth/presentation/providers/auth_providers.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && context.mounted) {
          context.go('/profile');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in to Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Your profile is private.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please sign in or create an account to access your profile information and saved progress.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : () => context.push('/login'),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: authState.isLoading ? null : () => context.push('/signup'),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: const Text('Back to Feed'),
            ),
          ],
        ),
      ),
    );
  }
}
