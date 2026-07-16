import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../shared/models/company.dart';
import '../data/auth_repository.dart';

/// Self-registration: dropdown-driven, no role selection. The account
/// stays inactive until technical assigns a role.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _department = TextEditingController();
  final _branch = TextEditingController();
  final _position = TextEditingController();
  int? _companyId;
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [
      _name, _email, _password, _passwordConfirm, _department, _branch, _position,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      await ref.read(authRepositoryProvider).register({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'password_confirmation': _passwordConfirm.text,
        'company_id': _companyId,
        'department': _department.text.trim(),
        if (_branch.text.trim().isNotEmpty) 'branch': _branch.text.trim(),
        'position': _position.text.trim(),
      });

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration received'),
          content: const Text(
            'Your account will be activated once the technical department assigns your role. You will then be able to sign in.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/login');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  companies.when(
                    data: (List<Company> items) => DropdownButtonFormField<int>(
                      initialValue: _companyId,
                      decoration: const InputDecoration(labelText: 'Company'),
                      items: [
                        for (final company in items)
                          DropdownMenuItem(
                            value: company.id,
                            child: Text('${company.code} - ${company.name}'),
                          ),
                      ],
                      onChanged: (value) => setState(() => _companyId = value),
                      validator: (value) => value == null ? 'Select your company' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => Text(apiErrorMessage(error)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _department,
                    decoration: const InputDecoration(labelText: 'Department'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _branch,
                    decoration: const InputDecoration(labelText: 'Branch (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _position,
                    decoration: const InputDecoration(labelText: 'Position'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.length < 8) ? 'At least 8 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordConfirm,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                    validator: (value) =>
                        value != _password.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? 'Submitting...' : 'Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;
}
