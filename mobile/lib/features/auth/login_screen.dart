import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _loginMethod = 'email'; // 'email' or 'phone'

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.login(
        email: _loginMethod == 'email' ? _emailOrPhoneController.text.trim() : null,
        phoneNumber: _loginMethod == 'phone' ? _emailOrPhoneController.text.trim() : null,
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pushReplacementNamed(Routes.main);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('login')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Homia',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Karibu! Welcome back',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Login Method Toggle
              Center(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'email',
                      label: Text('Email'),
                      icon: Icon(Icons.email_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: 'phone',
                      label: Text('Phone'),
                      icon: Icon(Icons.phone_outlined, size: 18),
                    ),
                  ],
                  selected: {_loginMethod},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _loginMethod = selection.first;
                      _emailOrPhoneController.clear();
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Email or Phone Input
              TextFormField(
                controller: _emailOrPhoneController,
                keyboardType: _loginMethod == 'email' 
                    ? TextInputType.emailAddress 
                    : TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _loginMethod == 'email' ? 'Email Address' : 'Phone Number',
                  hintText: _loginMethod == 'email' ? 'example@email.com' : '+255XXXXXXXXX',
                  prefixIcon: Icon(_loginMethod == 'email' 
                      ? Icons.email_outlined 
                      : Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _loginMethod == 'email' 
                        ? 'Please enter your email'
                        : 'Please enter your phone number';
                  }
                  if (_loginMethod == 'email' && !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  if (_loginMethod == 'phone' && !value.startsWith('+255')) {
                    return 'Phone must start with +255';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.translate('password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Login Button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _login,
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.translate('login')),
              ),
              
              const SizedBox(height: 16),
              
              // Register Link
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.register);
                },
                child: Text(l10n.translate('register')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





