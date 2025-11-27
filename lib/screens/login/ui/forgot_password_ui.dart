import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/login_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/decorative_footer.dart';

class ForgotPasswordUi extends StatefulWidget {
  const ForgotPasswordUi({super.key});

  @override
  State<ForgotPasswordUi> createState() => _ForgotPasswordUiState();
}

class _ForgotPasswordUiState extends State<ForgotPasswordUi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  
  ForgotPasswordState _state = const ForgotPasswordState();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _state = _state.copyWith(isLoading: true, errorMessage: null);
    });

    try {
      // Simulate password reset process
      await Future.delayed(const Duration(seconds: 2));
      
      // Create forgot password form data
      final formData = ForgotPasswordFormData(
        email: _emailController.text.trim(),
      );

      // Validate form data
      if (!LoginValidator.isValidForgotPasswordForm(formData)) {
        setState(() {
          _state = _state.copyWith(
            isLoading: false,
            errorMessage: 'Please enter a valid email address',
          );
        });
        return;
      }

      // Show success message
      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          isEmailSent: true,
        );
      });

      // Show success dialog
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send reset email. Please try again.',
        );
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Email Sent!',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to login
            },
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'CHECK',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              TextSpan(
                text: 'INN',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  background: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 100, 30)),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Header section
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 30,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  "Forgot Password?",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Don't worry! It happens. Please enter the email address associated with your account.",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  hintText: "Enter your email address",
                  prefixIcon: Icons.email_outlined,
                  validator: LoginValidator.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 32),

                // Error message
                if (_state.errorMessage != null)
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
                      _state.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Reset password button
                GradientButton(
                  text: "Send Reset Link",
                  onPressed: _handleResetPassword,
                  isLoading: _state.isLoading,
                ),

                const SizedBox(height: 24),

                // Back to login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Remember your password? ",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Decorative footer
                const DecorativeFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
