import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/firebase_phone_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _role = 'guest';
  String _verificationMethod = 'email'; // 'email' or 'phone'

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      // For phone verification, use Firebase directly (Google SMS)
      if (_verificationMethod == 'phone') {
        // Show loading
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Send verification code via Firebase (Google SMS)
        final firebaseAuth = FirebasePhoneAuthService();
        final result = await firebaseAuth.sendVerificationCode(
          _phoneController.text.trim(),
        );

        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading

        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📱 SMS sent by Google to ${_phoneController.text}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to verification screen
          Navigator.of(context).pushNamed(
            Routes.verification,
            arguments: {
              'verificationType': 'phone',
              'contact': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'role': _role,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send SMS: ${result['error'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Email verification - use backend
        final success = await authProvider.register(
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          role: _role,
        );
        
        if (!mounted) return;
        
        if (success) {
          bool codeSent = await authProvider.sendEmailCode(_emailController.text.trim());
          
          if (!mounted) return;
          
          if (codeSent) {
            Navigator.of(context).pushNamed(
              Routes.verification,
              arguments: {
                'verificationType': 'email',
                'contact': _emailController.text.trim(),
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('register')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
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
                'Jisajili leo! Register today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: l10n.translate('first_name'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: l10n.translate('last_name'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.translate('email'),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.translate('phone_number'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '+255712345678',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!value.startsWith('+255')) {
                    return 'Phone number must start with +255';
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
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Role Selection
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'I want to',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'guest', child: Text('Find a place to stay')),
                  DropdownMenuItem(value: 'host', child: Text('List my property')),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value ?? 'guest';
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Verification Method Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify your account via:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: const [
                                Icon(Icons.email_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Email'),
                              ],
                            ),
                            value: 'email',
                            groupValue: _verificationMethod,
                            onChanged: (value) {
                              setState(() {
                                _verificationMethod = value ?? 'email';
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: const [
                                Icon(Icons.phone_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Phone'),
                              ],
                            ),
                            value: 'phone',
                            groupValue: _verificationMethod,
                            onChanged: (value) {
                              setState(() {
                                _verificationMethod = value ?? 'phone';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Register Button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _register,
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.translate('register')),
              ),
              
              const SizedBox(height: 16),
              
              // Login Link
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.login);
                },
                child: Text(l10n.translate('login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





