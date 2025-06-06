import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;
  bool isFormValid = false;

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ApiService.login(
      usernameController.text.trim(),
      passwordController.text,
    );

    if (success) {
      Navigator.of(context).pushReplacementNamed('/feed');
    } else {
      setState(() => error = 'Login failed. Check your credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: Column(
            children: [
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Enter username' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter password' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isFormValid ? handleLogin : null,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}