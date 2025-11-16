import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/config/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/firebase_phone_auth_service.dart';

class VerificationScreen extends StatefulWidget {
  final String verificationType; // 'email' or 'phone'
  final String contact; // email address or phone number
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? role;
  
  const VerificationScreen({
    super.key,
    required this.verificationType,
    required this.contact,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.role,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isResending = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _verify() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      if (widget.verificationType == 'phone') {
        // Use Firebase Phone Auth (Google SMS)
        final firebaseAuth = FirebasePhoneAuthService();
        final result = await firebaseAuth.verifyCode(_codeController.text.trim());
        
        if (!mounted) return;
        
        if (result['success'] == true) {
          // Phone verified by Google! Now register with backend
          final success = await authProvider.register(
            email: widget.email!,
            phoneNumber: widget.contact,
            password: widget.password!,
            firstName: widget.firstName!,
            lastName: widget.lastName!,
            role: widget.role ?? 'renter',
          );
          
          if (!mounted) return;
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Phone verified by Google! Account created!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacementNamed(Routes.main);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Registration failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Invalid verification code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Email verification - use backend
        bool success = await authProvider.verifyEmail(_codeController.text.trim());
        
        if (!mounted) return;
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed(Routes.main);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Verification failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    if (widget.verificationType == 'phone') {
      // Resend via Firebase (Google SMS)
      final firebaseAuth = FirebasePhoneAuthService();
      final result = await firebaseAuth.resendCode(widget.contact);
      
      if (!mounted) return;

      setState(() {
        _isResending = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 New SMS sent by Google!'),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to resend code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Resend via backend for email
      final authProvider = context.read<AuthProvider>();
      bool success = await authProvider.sendEmailCode(widget.contact);

      if (!mounted) return;

      setState(() {
        _isResending = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code resent to ${widget.contact}'),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to resend code'),
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
    final isPhone = widget.verificationType == 'phone';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isPhone ? 'Verify Phone' : 'Verify Email'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'We sent a verification code to\n${widget.contact}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Code Input
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '● ● ● ● ● ●',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter verification code';
                  }
                  if (value.length != 6) {
                    return 'Code must be 6 digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (_countdown > 0)
                    Text(
                      'Resend in ${_countdown}s',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (_isResending)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Change method link
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  isPhone ? Icons.email_outlined : Icons.phone_outlined,
                  size: 20,
                ),
                label: Text(
                  isPhone ? 'Verify via Email instead' : 'Verify via Phone instead',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

