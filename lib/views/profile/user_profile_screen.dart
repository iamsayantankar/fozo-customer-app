import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/views/profile/map_location_screen_profile_update.dart';

import '../../core/constants/colour_constants.dart';
import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/http/api.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map userLookup = {};
  Map userRes = {};

  @override
  void initState() {
    super.initState();
    _getDetails();
  }

  Future<void> _getDetails() async {
    final res = await ApiService.getRequest("profile/customer");
    String? userLookUpString =
        await SharedPreferencesHelper.getString("userLookup");
    userLookup = jsonDecode(userLookUpString!);

    setState(() {
      userRes = res;
      _controllers = {
        "Name": TextEditingController(text: res["full_name"]),
        "Mobile":
            TextEditingController(text: userLookup["user"]["contact_number"]),
        "Email": TextEditingController(text: userLookup["user"]["email"]),
        "Address": TextEditingController(text: res["address"]),
      };
    });
  }

  final Map<String, bool> _isEditing = {
    "Name": false,
    "Mobile": false,
    "Email": false,
    "Address": false,
    // "DOB": false,
    // "Gender": false,
  };

  Map<String, TextEditingController> _controllers = {
    "Name": TextEditingController(text: ""),
    "Mobile": TextEditingController(text: ""),
    "Email": TextEditingController(text: ""),
    "Address": TextEditingController(text: ""),
  };

  void _toggleEdit(String field) async {
    if (_isEditing[field]!) {
      // Save: Call your API and update logic here
      final newValue = _controllers[field]!.text;

      String sendKey = "n/a";

      if (field == "Address") sendKey = "address";
      if (field == "Name") sendKey = "full_name";
      final res = await ApiService.putRequest(
          "profile/customer/" + userRes["customer_id"].toString(),
          {sendKey: newValue});

      // Example placeholder:
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isEditing[field] = !_isEditing[field]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Your Profile",
            style: TextStyle(color: Colors.black, fontSize: 16.sp)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._controllers.keys.map((field) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildProfileField(
                    label: field,
                    controller: _controllers[field]!,
                    isEditing: _isEditing[field]!,
                    onToggleEdit: () => _toggleEdit(field),
                  ),
                )),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggleEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isEditing
                    ? TextFormField(
                        controller: controller,
                        style: TextStyle(fontSize: 14.sp),
                        decoration:
                            const InputDecoration.collapsed(hintText: ""),
                      )
                    : Text(
                        controller.text,
                        style:
                            TextStyle(fontSize: 14.sp, color: Colors.black87),
                      ),
              ),
              (label == "Name")
                  ? GestureDetector(
                      onTap: onToggleEdit,
                      child: Text(
                        isEditing ? "Save" : "Change",
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColor.buttonColor),
                      ),
                    )
                  : (label == "Address")
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateDeliveryLocationScreen()),
                            );
                          },
                          child: Text(
                            isEditing ? "Save" : "Change",
                            style: TextStyle(
                                fontSize: 14.sp, color: AppColor.buttonColor),
                          ),
                        )
                      : SizedBox(height: 0, width: 0),
            ],
          ),
        ),
      ],
    );
  }
}
