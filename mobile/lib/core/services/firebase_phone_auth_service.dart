import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  /// Send verification code to phone number
  Future<Map<String, dynamic>> sendVerificationCode(String phoneNumber) async {
    try {
      print('🔥 Firebase: Sending verification code to: $phoneNumber');

      final Map<String, dynamic> result = {};
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // SMS sent successfully
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          print('🔥 Firebase: Auto-verification completed');
          result['autoVerified'] = true;
          result['credential'] = credential;
        },
        
        // SMS failed to send
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Firebase: Verification failed: ${e.message}');
          result['error'] = e.message ?? 'Verification failed';
        },
        
        // SMS sent successfully
        codeSent: (String verificationId, int? resendToken) {
          print('✅ Firebase: SMS code sent successfully!');
          _verificationId = verificationId;
          _resendToken = resendToken;
          result['success'] = true;
          result['verificationId'] = verificationId;
        },
        
        // Timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Firebase: Auto-retrieval timeout');
          _verificationId = verificationId;
        },
        
        forceResendingToken: _resendToken,
      );

      // Wait for result
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (result.isEmpty) {
        return {'success': true, 'verificationId': _verificationId};
      }

      return result;
    } catch (e) {
      print('❌ Firebase: Error sending verification code: $e');
      return {'error': e.toString()};
    }
  }

  /// Verify the SMS code entered by user
  Future<Map<String, dynamic>> verifyCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        return {'error': 'No verification in progress'};
      }

      print('🔥 Firebase: Verifying SMS code...');

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      print('✅ Firebase: Phone verified successfully: ${userCredential.user?.phoneNumber}');

      return {
        'success': true,
        'uid': userCredential.user?.uid,
        'phoneNumber': userCredential.user?.phoneNumber,
        'idToken': await userCredential.user?.getIdToken(),
      };
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase: Verification error: ${e.message}');
      
      String errorMessage = 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid code. Please try again.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'Code expired. Please request a new one.';
      }
      
      return {'error': errorMessage};
    } catch (e) {
      print('❌ Firebase: Error verifying code: $e');
      return {'error': e.toString()};
    }
  }

  /// Resend verification code
  Future<Map<String, dynamic>> resendCode(String phoneNumber) async {
    return await sendVerificationCode(phoneNumber);
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if user is signed in with phone
  bool get isSignedIn => _auth.currentUser != null;

  /// Get phone number of current user
  String? get currentPhoneNumber => _auth.currentUser?.phoneNumber;
}

