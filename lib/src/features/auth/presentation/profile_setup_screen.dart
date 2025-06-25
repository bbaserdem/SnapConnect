/// Profile setup screen that allows users to complete their profile
/// This screen is shown after sign up to collect additional user information

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/auth_state_notifier.dart';

/// Available interest tags for users to select from
const availableInterestTags = [
  'Tattoos',
  'Piercings',
  'Body Modification',
  'Scarification',
  'Traditional',
  'Neo-Traditional',
  'Japanese',
  'Blackwork',
  'Color',
  'Minimalist',
  'Geometric',
  'Custom Jewelry',
  'Implants',
];

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
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileSetup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final user = ref.read(authUserProvider).value;
        if (user == null) {
          throw Exception('User not found');
        }

        // Update the user's profile in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'bio': _bioController.text.trim(),
          'interest_tags': _selectedInterests.toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          context.go('/'); // Navigate to home screen after profile setup
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  hintText: 'Share a bit about yourself...',
                ),
                maxLength: 150,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Select your interests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableInterestTags.map((tag) {
                  final isSelected = _selectedInterests.contains(tag);
                  return FilterChip(
                    label: Text(tag),
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
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _handleProfileSetup,
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
            ],
          ),
        ),
      ),
    );
  }
} 