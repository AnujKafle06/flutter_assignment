// test/auth_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/fire_base_auth/auth_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    // Helper function to create the widget with proper setup
    Widget createTestWidget() {
      return MaterialApp(home: const AuthScreen());
    }

    testWidgets('should display login form by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for login-specific elements
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue to your account'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsAtLeastNWidgets(1));
    });

    testWidgets('should toggle to signup form when signup button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the signup toggle button
      final signUpButton = find.byType(TextButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Check for signup-specific elements
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Fill in your details to get started'), findsOneWidget);
      expect(find.text("Already have an account?"), findsOneWidget);
      expect(find.text('Sign In'), findsAtLeastNWidgets(1));
    });

    testWidgets('should have email and password text fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have exactly 2 TextFormFields (email and password)
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Check for email field
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);

      // Check for password field
      expect(find.text('Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('should validate empty email field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the submit button and tap it without entering any data
      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error for email
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid email but leave password empty
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Try to submit
      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error for password
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email format
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      // Try to submit
      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error for email format
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password length in signup mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to signup mode
      final toggleButton = find.byType(TextButton);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Enter valid email but short password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');

      // Try to submit
      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error for password length
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility_outlined);
      expect(visibilityToggle, findsOneWidget);

      // Tap to show password
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Should now show the hide password icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should show remember me checkbox in login mode only', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // In login mode, should have remember me checkbox
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);

      // Switch to signup mode
      final toggleButton = find.byType(TextButton);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // In signup mode, should not have remember me checkbox
      expect(find.byType(CheckboxListTile), findsNothing);
    });

    testWidgets('should toggle remember me checkbox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap remember me checkbox
      final checkbox = find.byType(CheckboxListTile);
      expect(checkbox, findsOneWidget);

      // Get initial state (should be false)
      CheckboxListTile checkboxWidget =
          tester.widget(checkbox) as CheckboxListTile;
      expect(checkboxWidget.value, isFalse);

      // Tap the checkbox
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Should now be true
      checkboxWidget = tester.widget(checkbox) as CheckboxListTile;
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets('should clear errors when switching modes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger validation error
      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should have validation errors
      expect(find.text('Email is required'), findsOneWidget);

      // Switch to signup mode
      final toggleButton = find.byType(TextButton);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Errors should be cleared
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('should have proper form structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have a Form widget
      expect(find.byType(Form), findsOneWidget);

      // Should have a Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      // Should have a SafeArea
      expect(find.byType(SafeArea), findsOneWidget);

      // Should have a SingleChildScrollView for keyboard handling
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have security icon in header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have security icon
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('should have proper button states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have one ElevatedButton (Submit)
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Should have one TextButton (Toggle mode)
      expect(find.byType(TextButton), findsOneWidget);

      // Submit button should be enabled initially
      final submitButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('should handle text input correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text in email field
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Enter text in password field
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    group('AuthScreen Form Validation Tests', () {
      Widget createTestWidget() {
        return MaterialApp(home: const AuthScreen());
      }

      testWidgets('should pass validation with valid inputs', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid credentials
        final emailField = find.byType(TextFormField).first;
        final passwordField = find.byType(TextFormField).last;

        await tester.enterText(emailField, 'valid@example.com');
        await tester.enterText(passwordField, 'validpassword123');

        // Submit the form
        final submitButton = find.byType(ElevatedButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Should not show validation errors
        expect(find.text('Email is required'), findsNothing);
        expect(find.text('Please enter a valid email'), findsNothing);
        expect(find.text('Password is required'), findsNothing);
      });

      testWidgets('should validate multiple email formats', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final invalidEmails = [
          'invalid',
          'invalid@',
          '@invalid.com',
          'invalid.com',
          'invalid@.com',
          'invalid@com.',
        ];

        for (final email in invalidEmails) {
          // Clear previous text
          final emailField = find.byType(TextFormField).first;
          await tester.enterText(emailField, '');
          await tester.enterText(emailField, email);

          final submitButton = find.byType(ElevatedButton);
          await tester.tap(submitButton);
          await tester.pumpAndSettle();

          // Should show validation error
          expect(find.text('Please enter a valid email'), findsOneWidget);
        }
      });
    });
  });
}
