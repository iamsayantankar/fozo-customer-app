import 'dart:convert';

import 'package:http/http.dart' as http;

import '../helper/shared_preferences_helper.dart';

class ApiService {
  static const String baseUrl =
      "https://api.getfozo.in/api/"; // Change this to your API base URL

  // GET Request
  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');

      // final headers = await _getHeadersGorGetReq();
      final headers = await _getHeaders();

      print(Uri.parse(encodedUrl));
      print(headers);

      final response = await http.get(Uri.parse(encodedUrl), headers: headers);
      final responseJson = jsonDecode(response.body);
      return _handleResponse(response);
    } catch (e) {
      print('GET Request Error: $e');
      return {};
    }
  }

  // POST Request
  static Future<Map<String, dynamic>> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');
      final headers = await _getHeaders();

      print(encodedUrl);
      print(headers);
      print(data);

      final response = await http.post(
        Uri.parse(encodedUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      final responseJson = jsonDecode(response.body);
      return _handleResponse(response);
    } catch (e) {
      print('POST Request Error: $e');
      return {};
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> putRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse(encodedUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('PUT Request Error: $e');
      return {};
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    try {
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');
      final headers = await _getHeaders();

      final response =
          await http.delete(Uri.parse(encodedUrl), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('DELETE Request Error: $e');
      return {};
    }
  }

// Replace this static headers block:
// static final Map<String, String> _headers = { ... };

  static Future<Map<String, String>> _getHeaders() async {
    String? userLookUpString =
        await SharedPreferencesHelper.getString("userLookup");

    String? token;
    if (userLookUpString != null) {
      Map userLookup = jsonDecode(userLookUpString);
      token = userLookup["token"];
    }

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _getHeadersGorGetReq() async {
    String? userLookUpString =
        await SharedPreferencesHelper.getString("userLookup");

    String? token;
    if (userLookUpString != null) {
      Map userLookup = jsonDecode(userLookUpString);
      token = userLookup["token"];
    }

    return {
      // 'Accept': '*/*',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print(response.statusCode);
    print(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('HTTP Error: ${response.statusCode} - ${response.body}');
      return {};
    }
  }
}
