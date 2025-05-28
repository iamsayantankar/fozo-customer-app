// fozo_home_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';

class FozoHomeProvider extends ChangeNotifier {
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  // Example lists that we fetch from an API
  List topRatedItems = [];
  List allOutlets = [];

  // Simulated API call
  Future<void> fetchHomeData() async {
    try {
      isLoading = true;
      hasError = false;
      // notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Replace this with your real API call logic
      // For example, final response = await http.get("YOUR_API_ENDPOINT");
      // Parse JSON, etc.

      // Dummy data
      topRatedItems = [];

      allOutlets = [];

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
