import 'package:flutter/material.dart';

class Agent {
  final String name;
  final String status;
  final String company;
  final String photoUrl;
  final String mobile;
  final String altMobile;
  final String email;
  final String address;

  const Agent({
    required this.name,
    required this.status,
    required this.company,
    required this.photoUrl,
    required this.mobile,
    required this.altMobile,
    required this.email,
    required this.address,
  });

  factory Agent.fromMap(Map<String, String> map) {
    return Agent(
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      company: map['company'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      mobile: map['mobile'] ?? '',
      altMobile: map['altMobile'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'status': status,
      'company': company,
      'photoUrl': photoUrl,
      'mobile': mobile,
      'altMobile': altMobile,
      'email': email,
      'address': address,
    };
  }

  Agent copyWith({
    String? name,
    String? status,
    String? company,
    String? photoUrl,
    String? mobile,
    String? altMobile,
    String? email,
    String? address,
  }) {
    return Agent(
      name: name ?? this.name,
      status: status ?? this.status,
      company: company ?? this.company,
      photoUrl: photoUrl ?? this.photoUrl,
      mobile: mobile ?? this.mobile,
      altMobile: altMobile ?? this.altMobile,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}

class AgentStatus {
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  
  static List<String> get all => [active, inactive];
}

class AgentHelper {
  static Color getStatusColor(String status) {
    return status.toLowerCase() == "active" 
        ? const Color(0xFF22C55E) 
        : const Color(0xFFEF4444);
  }
}
