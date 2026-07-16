import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../application/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_name, _email, _currentPassword, _newPassword, _confirmPassword]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save(Map<String, dynamic> payload, String success) async {
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value?.user;
    if (user == null) return const SizedBox.shrink();

    if (_name.text.isEmpty) _name.text = user.name;
    if (_email.text.isEmpty) _email.text = user.email;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('ID: ${user.code}'),
                Text('Company: ${user.company?.name ?? ''}'),
                Text('Department: ${user.department}'),
                Text('Position: ${user.position}'),
                Text('Role: ${user.role?.name ?? 'pending assignment'}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _save(
                    {'name': _name.text.trim(), 'email': _email.text.trim()},
                    'Profile updated.',
                  ),
                  child: const Text('Save profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Change password', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _currentPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _save(
                    {
                      'current_password': _currentPassword.text,
                      'password': _newPassword.text,
                      'password_confirmation': _confirmPassword.text,
                    },
                    'Password changed.',
                  ),
                  child: const Text('Change password'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}
