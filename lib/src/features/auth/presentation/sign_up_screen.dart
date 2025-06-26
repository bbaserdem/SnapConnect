// Sign up screen that allows users to create a new account
// This screen handles form validation and displays error messages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_state_notifier.dart';
import '../data/auth_repository.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isUsernameChecking = false;
  bool _isUsernameAvailable = true;
  String? _usernameError;

  // Track the current username being checked to prevent race conditions
  String? _currentUsernameCheck;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Check username availability with debouncing and race condition prevention
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) return;

    // First validate format before checking availability
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _isUsernameChecking = false;
        _isUsernameAvailable = false;
        _usernameError =
            'Username can only contain letters, numbers, and underscores';
      });
      return;
    }

    // Set the current username being checked to prevent race conditions
    final normalizedUsername = username.toLowerCase();
    _currentUsernameCheck = normalizedUsername;

    setState(() {
      _isUsernameChecking = true;
      _usernameError = null;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final isAvailable = await authRepository.isUsernameAvailable(
        normalizedUsername,
      );

      // Only update state if this is still the current username being checked
      if (mounted && _currentUsernameCheck == normalizedUsername) {
        setState(() {
          _isUsernameAvailable = isAvailable;
          _isUsernameChecking = false;
          _usernameError = isAvailable ? null : 'Username is already taken';
        });
      }
    } catch (e) {
      // Only update state if this is still the current username being checked
      if (mounted && _currentUsernameCheck == normalizedUsername) {
        setState(() {
          _isUsernameChecking = false;
          _isUsernameAvailable = false;
          _usernameError =
              'Failed to check username availability: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isUsernameChecking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while we check username availability'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a different username'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ref
          .read(authStateNotifierProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          );

      if (mounted) {
        // Success message will be shown, routing handled by router
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Account created successfully! Please complete your profile.',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');

        // Show user-friendly error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Sign Up Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 16),
                if (errorMessage.toLowerCase().contains('email') &&
                    errorMessage.contains('already'))
                  const Text(
                    '💡 Already have an account? Try signing in instead.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                if (errorMessage.toLowerCase().contains('password') &&
                    errorMessage.contains('weak'))
                  const Text(
                    '💡 Try using a mix of uppercase, lowercase, numbers, and symbols.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              if (errorMessage.toLowerCase().contains('email') &&
                  errorMessage.contains('already'))
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/signin');
                  },
                  child: const Text('Sign In'),
                ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join SnapConnect',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect with the body modification community',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: _isUsernameChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _usernameController.text.length >= 3
                      ? Icon(
                          _isUsernameAvailable
                              ? Icons.check_circle
                              : Icons.error,
                          color: _isUsernameAvailable
                              ? Colors.green
                              : Colors.red,
                        )
                      : null,
                  errorText: _usernameError,
                ),
                onChanged: (value) {
                  if (value.length >= 3) {
                    // Debounce the username check
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted && _usernameController.text == value) {
                        _checkUsernameAvailability(value);
                      }
                    });
                  } else {
                    setState(() {
                      _usernameError = null;
                      _isUsernameAvailable = true;
                      _isUsernameChecking = false;
                      _currentUsernameCheck = null;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (value.length > 30) {
                    return 'Username must be less than 30 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Username can only contain letters, numbers, and underscores';
                  }
                  // Check if there's an ongoing availability check error
                  if (_usernameError != null) {
                    return _usernameError;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Sign up button
              FilledButton(
                onPressed: authState.isLoading ? null : _handleSignUp,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Account'),
              ),

              const SizedBox(height: 16),

              // Sign in link
              TextButton(
                onPressed: () => context.go('/signin'),
                child: const Text('Already have an account? Sign In'),
              ),

              const SizedBox(height: 16),

              // Terms and conditions
              Text(
                'By creating an account, you agree to our Terms of Service and Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
