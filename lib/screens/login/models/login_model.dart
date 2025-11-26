import 'package:flutter/material.dart';

/// Login form data model
class LoginFormData {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginFormData({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  LoginFormData copyWith({
    String? username,
    String? password,
    bool? rememberMe,
  }) {
    return LoginFormData(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  factory LoginFormData.fromMap(Map<String, dynamic> map) {
    return LoginFormData(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      rememberMe: map['rememberMe'] ?? false,
    );
  }
}

/// Forgot password form data model
class ForgotPasswordFormData {
  final String email;

  const ForgotPasswordFormData({
    required this.email,
  });

  ForgotPasswordFormData copyWith({
    String? email,
  }) {
    return ForgotPasswordFormData(
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
    };
  }

  factory ForgotPasswordFormData.fromMap(Map<String, dynamic> map) {
    return ForgotPasswordFormData(
      email: map['email'] ?? '',
    );
  }
}

/// Login validation helper
class LoginValidator {
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static bool isValidLoginForm(LoginFormData formData) {
    return validateUsername(formData.username) == null &&
           validatePassword(formData.password) == null;
  }

  static bool isValidForgotPasswordForm(ForgotPasswordFormData formData) {
    return validateEmail(formData.email) == null;
  }
}

/// Login state management
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool rememberMe;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.rememberMe = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? rememberMe,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

/// Forgot password state management
class ForgotPasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmailSent;

  const ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isEmailSent = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isEmailSent,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isEmailSent: isEmailSent ?? this.isEmailSent,
    );
  }
}
