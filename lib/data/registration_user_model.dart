// register_user_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class RegisterUserService {
  /// This method calls your backend to store user info
  static Future<String> registerUser({
    required String name,
    required String phoneNumber,
    required String firebaseUid,
  }) async {
    final url = Uri.parse('https://api.getfozo.in/api/auth/register/customer');

    // We get the current Firebase ID token from the user
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'idToken': idToken,
          'fullName': name,
          'contactNumber': phoneNumber,
          'profileImage': "Pseudo Image",
          'address': '', // if you want an address, pass it here
        }),
      );

      if (response.statusCode == 200) {
        // Return the raw response body if you need it
        return response.body;
      } else {
        throw Exception(
          'Failed to register user. '
          'Status code: ${response.statusCode}, Response: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('RegisterUserService Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
