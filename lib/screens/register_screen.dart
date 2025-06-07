import 'dart:ui';
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
      backgroundColor: Colors.grey[100],
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_background.jpg',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 6,
                color: Colors.black.withValues(alpha: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                  child: Form(
                    key: _formKey,
                    onChanged: _validateForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Create your Feels account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Enter username' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Enter email';
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value.trim())) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          obscureText: true,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          obscureText: true,
                          validator: (value) =>
                          value != passwordController.text ? 'Passwords do not match' : null,
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            error!,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isFormValid ? handleRegister : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Register'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}