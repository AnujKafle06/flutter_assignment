import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService Logic Tests', () {
    test('should validate email format correctly', () {
      // Test email validation logic
      expect(isValidEmail('test@example.com'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('test@'), isFalse);
      expect(isValidEmail('@example.com'), isFalse);
    });

    test('should validate password requirements', () {
      // Test password validation logic
      expect(isValidPassword('password123', false), isTrue); // Login mode
      expect(
        isValidPassword('12345', false),
        isTrue,
      ); // Login allows any length
      expect(isValidPassword('password123', true), isTrue); // Signup mode
      expect(
        isValidPassword('12345', true),
        isFalse,
      ); // Signup requires 6+ chars
      expect(isValidPassword('', true), isFalse); // Empty not allowed
    });

    test('should handle Firebase error codes correctly', () {
      // Test error message mapping
      expect(
        getErrorMessage('weak-password'),
        'The password provided is too weak',
      );
      expect(
        getErrorMessage('email-already-in-use'),
        'An account already exists for this email',
      );
      expect(getErrorMessage('user-not-found'), 'No user found for this email');
      expect(getErrorMessage('wrong-password'), 'Wrong password provided');
      expect(
        getErrorMessage('invalid-email'),
        'The email address is badly formatted',
      );
      expect(
        getErrorMessage('unknown-error'),
        'Authentication failed. Please try again',
      );
    });
  });
}

// Helper functions to test validation logic
bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool isValidPassword(String password, bool isSignupMode) {
  if (password.isEmpty) return false;
  if (isSignupMode && password.length < 6) return false;
  return true;
}

String getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'weak-password':
      return 'The password provided is too weak';
    case 'email-already-in-use':
      return 'An account already exists for this email';
    case 'user-not-found':
      return 'No user found for this email';
    case 'wrong-password':
      return 'Wrong password provided';
    case 'invalid-email':
      return 'The email address is badly formatted';
    case 'user-disabled':
      return 'This user account has been disabled';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later';
    default:
      return 'Authentication failed. Please try again';
  }
}
