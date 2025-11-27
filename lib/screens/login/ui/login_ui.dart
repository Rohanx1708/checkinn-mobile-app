import 'package:flutter/material.dart';
import 'package:checkinn/utils/routes.dart';
import '../models/login_model.dart';
import '../services/login_service.dart';
import '../widgets/login_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/decorative_footer.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  LoginState _loginState = const LoginState();
  bool _hasAttemptedValidation = false;

  @override
  void initState() {
    super.initState();
    // Clear error message when user starts editing email
    _usernameController.addListener(_clearErrorOnEdit);
    // Clear error message when user starts editing password
    _passwordController.addListener(_clearErrorOnEdit);
  }

  void _clearErrorOnEdit() {
    // Clear API error message
    if (_loginState.errorMessage != null) {
      setState(() {
        _loginState = _loginState.copyWith(clearErrorMessage: true);
      });
    }
    // Note: Form validation errors will clear automatically with autovalidateMode
    // when the user types valid input, so we don't need to manually validate here
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearErrorOnEdit);
    _passwordController.removeListener(_clearErrorOnEdit);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _loginState = _loginState.copyWith(
        isPasswordVisible: !_loginState.isPasswordVisible,
      );
    });
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }


  void _handleLogin() async {
    // Mark that validation has been attempted
    setState(() {
      _hasAttemptedValidation = true;
    });
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loginState = _loginState.copyWith(isLoading: true, errorMessage: null);
    });

    try {
      // Create login form data
      final loginData = LoginFormData(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        rememberMe: _loginState.rememberMe,
      );

      // Validate form data
      if (!LoginValidator.isValidLoginForm(loginData)) {
        setState(() {
          _loginState = _loginState.copyWith(
            isLoading: false,
            errorMessage: 'Please check your credentials',
          );
        });
        return;
      }

      // Call the login API
      final result = await LoginService.login(
        email: loginData.username,
        password: loginData.password,
      );

      if (result['success']) {
        // Store user data/token if needed
        // You can add SharedPreferences or other storage here
        
        // Navigate to dashboard after successful login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        }
      } else {
        setState(() {
          _loginState = _loginState.copyWith(
            isLoading: false,
            errorMessage: result['message'] ?? 'Login failed. Please try again.',
          );
        });
      }
    } catch (e) {
      setState(() {
        _loginState = _loginState.copyWith(
          isLoading: false,
          errorMessage: 'Network error. Please check your connection.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Logo and welcome text
                const LoginLogo(),

                const SizedBox(height: 50),

                // Username field
                CustomTextField(
                  controller: _usernameController,
                  hintText: "Username/Email",
                  prefixIcon: Icons.person_outline,
                  validator: LoginValidator.validateUsername,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: _hasAttemptedValidation 
                      ? AutovalidateMode.always 
                      : AutovalidateMode.disabled,
                ),

                const SizedBox(height: 24),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Your Password",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _loginState.isPasswordVisible,
                  onPasswordToggle: _togglePasswordVisibility,
                  validator: LoginValidator.validatePassword,
                  autovalidateMode: _hasAttemptedValidation 
                      ? AutovalidateMode.always 
                      : AutovalidateMode.disabled,
                ),

                // Forgot password link
                ForgotPasswordLink(onPressed: _handleForgotPassword),

                const SizedBox(height: 40),

                // Error message
                if (_loginState.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _loginState.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Login button
                GradientButton(
                  text: "Sign In",
                  onPressed: _handleLogin,
                  isLoading: _loginState.isLoading,
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
