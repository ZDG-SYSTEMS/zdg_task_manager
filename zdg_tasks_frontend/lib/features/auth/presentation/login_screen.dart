import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/logos/zdg.png', height: 120),
                  const SizedBox(height: 8),
                  Text(
                    'ZDG Tasks',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 16),
                  if (auth.hasError && !auth.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        apiErrorMessage(auth.error!),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  FilledButton(
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
