import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/views/auth/map_location_screen.dart';

import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/permission/permissions.dart';
import '../../widgets/custom_button_widget.dart';
import 'login_screen.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({
    super.key,
    // required this.phoneNumber,
    // required this.firebaseUid,
    // required this.idToken,
  });

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Map getData = {};

  Future<void> _saveUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        throw Exception("Name cannot be empty");
      }
      // Request all necessary app permissions (e.g., storage, location, etc.)
      await AppPermissions.requestAllPermissions();
      if (!mounted) return;

      String jsonString = jsonEncode({
        "pageName": "AddDeliveryLocationScreen",
        "phoneNumber": getData["phoneNumber"],
        "firebaseUid": getData["firebaseUid"],
        "idToken": getData["idToken"],
        "name": name,
      });

      await SharedPreferencesHelper.saveString("loginData", jsonString);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddDeliveryLocationScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    _getData();
  }

  Future<void> _getData() async {
    // Retrieve the stored user email to check login status
    String? jsonString = await SharedPreferencesHelper.getString("loginData");

    if (jsonString != null) {
      setState(() {
        getData = jsonDecode(jsonString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
        ),
        title: Text(
          "Information",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),

            /// Heading
            Text(
              "Tell us a bit about you",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            /// Secondary Label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "What should we call you?",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Color(0xFF073228), // Updated color
                ),
              ),
            ),

            SizedBox(height: 8.h),

            /// Name TextField
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "James Brown",
                hintStyle: TextStyle(
                  color: Color(0xFF99A0AD),
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  size: 24.sp,
                  color: Color(0xFF99A0AD), // directly set icon color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),

            // Show any error from registration
            if (_errorMessage != null) ...[
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],

            const Spacer(),

            /// Continue Button
            CustomButton(
              text: "Continue",
              onPressed: () {
                // Minimal check: phone length should be 10
                if (!_isLoading) {
                  _saveUserInfo(); // call the API to store info
                }
              },
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
