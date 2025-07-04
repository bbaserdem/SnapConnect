/// Profile setup screen that allows users to complete their profile
/// This screen is shown after sign up to collect additional user information

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../data/auth_state_notifier.dart';
import 'package:snapconnect/src/app/router.dart' show markProfileSetupComplete;
import 'package:snapconnect/src/common/utils/tag_service.dart';

/// Interest tags are now loaded dynamically from assets/tags.txt.
/// A curated subset (first 9 tags) is displayed to the user.

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final Set<String> _selectedInterests = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ensureNeedsSetup();
  }

  Future<void> _ensureNeedsSetup() async {
    // Placeholder for future logic – currently not used.
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileSetup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authUserProvider).value;
      if (user == null) {
        throw Exception('User not found');
      }

      final authRepository = ref.read(authRepositoryProvider);
      
      // Update the user's profile in Firestore
      await authRepository.updateUserProfile(
        uid: user.uid,
        bio: _bioController.text.trim(),
        interestTags: _selectedInterests.toList(),
      );
      
      // Mark profile setup as complete BEFORE navigation
      markProfileSetupComplete(user.uid);

      if (mounted) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
        
        // Small delay to ensure SnackBar shows, then navigate
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          // Navigate to profile page after profile setup
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Convert a tag to Title Case for display (e.g., "tattoos" -> "Tattoos")
  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false, // Disable back button since this is required
      ),
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
                        Icons.person_add,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to SnapConnect!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your profile to connect with the body modification community',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bio section
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  hintText: 'Share a bit about yourself and your interests...',
                  alignLabelWithHint: true,
                ),
                maxLength: 150,
                maxLines: 3,
                textAlignVertical: TextAlignVertical.top,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bio';
                  }
                  if (value.trim().length < 10) {
                    return 'Bio must be at least 10 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Interest tags section
              Text(
                'Select your interests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the body modification styles and interests that resonate with you',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              
              // Interest tags wrapped in a card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final tagsAsync = ref.watch(curatedTagsProvider);
                      return tagsAsync.when(
                        data: (tags) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            final isSelected = _selectedInterests.contains(tag);
                            return FilterChip(
                              label: Text(_titleCase(tag)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedInterests.add(tag);
                                  } else {
                                    _selectedInterests.remove(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Text('Failed to load tags: $e'),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Complete profile button
              FilledButton(
                onPressed: _isLoading ? null : _handleProfileSetup,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Complete Profile'),
              ),
              
              const SizedBox(height: 16),
              
              // Info text
              Text(
                'You can update your profile information later in settings',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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