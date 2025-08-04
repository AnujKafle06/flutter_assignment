// lib/auth_screen.dart - Enhanced Modern Version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/fire_base_auth/firestore_crud_screen.dart';

import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLogin = true;
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSavedCredentials();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduced for performance
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Simpler curve
      ),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.2), // Reduced offset
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut, // Simpler curve
          ),
        );

    // Start animation after a brief delay to reduce initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  Future<void> _loadSavedCredentials() async {
    // You can implement SharedPreferences here to remember email
    // For now, just a placeholder
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });

    // Add haptic feedback - using compatible method
    HapticFeedback.selectionClick();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!_isLogin && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact(); // Fixed: Use available method
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      User? user;
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        user = await _authService.signIn(email, password);
      } else {
        user = await _authService.signUp(email, password);
      }

      if (user != null && mounted) {
        HapticFeedback.lightImpact(); // Fixed: Use available method

        // Show success message briefly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLogin ? 'Welcome back!' : 'Account created successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(milliseconds: 2000),
          ),
        );

        // Navigate with simpler animation to reduce main thread work
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TaskCrudScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact(); // Fixed: Use available method

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = 'Authentication failed. Please try again';
      }

      setState(() {
        _error = errorMessage;
      });
    } catch (e) {
      HapticFeedback.heavyImpact(); // Fixed: Use available method
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 12, // Reduced shadow blur
                offset: const Offset(0, 4), // Reduced offset
              ),
            ],
          ),
          child: const Icon(Icons.security, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          _isLogin ? 'Welcome Back!' : 'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            inherit: true,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Sign in to continue to your account'
              : 'Fill in your details to get started',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            inherit: true,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    if (_error == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
                inherit: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        style: TextStyle(inherit: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[50]
              : Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLogin ? 'Sign In' : 'Create Account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  inherit: true,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _loading ? null : _toggleMode,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            inherit: true,
          ),
          children: [
            TextSpan(
              text: _isLogin
                  ? "Don't have an account? "
                  : "Already have an account? ",
            ),
            TextSpan(
              text: _isLogin ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                inherit: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    if (!_isLogin) return const SizedBox.shrink();

    return CheckboxListTile(
      title: Text('Remember me', style: TextStyle(inherit: true)),
      value: _rememberMe,
      onChanged: (value) {
        setState(() {
          _rememberMe = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildErrorMessage(),
                // Simplified form without heavy animations
                Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        _passwordFocusNode.requestFocus();
                      },
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      validator: _validatePassword,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _submit,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    _buildRememberMe(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildToggleButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
