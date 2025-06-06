import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? error;
  bool isFormValid = false;

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ApiService.register(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );

    if (success) {
      Navigator.of(context).pushReplacementNamed('/feed');
    } else {
      setState(() => error = 'Registration failed. Try different credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value.trim())) return 'Invalid email';
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter password' : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) =>
                value != passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isFormValid ? handleRegister : null,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}