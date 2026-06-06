import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/domain/entities/user.dart';
import 'package:problem_solvers_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:problem_solvers_hub/core/utils/validation_utils.dart';
import 'package:problem_solvers_hub/core/exceptions/app_exception.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() => _errorMessage = null);

      try {
        ValidationUtils.validateSignupForm(
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
          _displayNameController.text.trim(),
        );

        ref.read(authProvider.notifier).signup(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e is AppException ? e.message : e.toString();
        });
      }
    } else if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms & Conditions';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Handle navigation on successful signup
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          context.go('/profile');
        }
      });

      next.maybeWhen(
        error: (error, stackTrace) {
          if (mounted) {
            setState(() {
              _errorMessage = error is Exception
                ? error.toString()
                : 'An error occurred during signup';
            });
          }
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 16),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Join ProblemSolvers Hub',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Display Name field
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        hintText: 'Display Name',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Display name is required';
                        }
                        try {
                          ValidationUtils.validateDisplayName(value!);
                          return null;
                        } catch (e) {
                          return e is AppException ? e.message : 'Invalid name';
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email is required';
                        }
                        try {
                          ValidationUtils.validateEmail(value!);
                          return null;
                        } catch (e) {
                          return e is AppException ? e.message : 'Invalid email';
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Password is required';
                        }
                        try {
                          ValidationUtils.validatePassword(value!);
                          return null;
                        } catch (e) {
                          return e is AppException ? e.message : 'Invalid password';
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Confirm password is required';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Terms & Conditions checkbox
                    CheckboxListTile(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() => _agreeToTerms = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I agree to Terms & Conditions',
                        style: TextStyle(fontSize: 14),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),

                    // Sign Up button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleSignup,
                        child: authState.isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Create Account'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
