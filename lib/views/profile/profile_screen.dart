import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/views/profile/past_order_screen.dart';

import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/http/api.dart';
import 'address_book_screen.dart';
import 'user_profile_screen.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            // 1) Profile Card
            Container(
              // The actual card with pale green background
              decoration: BoxDecoration(
                color: const Color(0xFFF6FCEB), // Pale green
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  // 1) Circle Avatar
                  // CircleAvatar(
                  //   radius: 28.r,
                  //   backgroundColor: Colors.grey.shade300,
                  //   backgroundImage: NetworkImage(
                  //     "https://via.placeholder.com/150",
                  //   ), // Replace with actual image
                  // ),

                  Icon(
                    Icons.person,
                    color: Colors.grey.shade900,
                    size: 28,
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          // userLookup["user"][""] ?? "",
                          userRes["full_name"] ?? "",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6.h),

                        // "You saved 0.7kg Co2 on this order" row
                        Row(
                          children: [
                            // Icon (cloud/eco)
                            Icon(
                              Icons.eco,
                              color: Colors.green.shade900,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),

                            // Partial text: "You saved " + "0.7kg Co2" + " on this order"
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: "You saved "),
                                  TextSpan(
                                    text: "0.7kg Co2",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                  const TextSpan(text: " on this order"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // 2) Your Profile
            _buildListItem(
              icon: Icons.person_outline,
              title: "Your Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfileScreen()),
                );
              },
            ),
            SizedBox(height: 12.h),

            // 3) Past Orders
            _buildListItem(
              icon: Icons.history, // or any other icon
              title: "Past Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PastOrderScreen()),
                );
              },
            ),
            SizedBox(height: 12.h),

            // 4) Address Book
            _buildListItem(
              icon: Icons.location_on_outlined,
              title: "Address Book",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddressBookScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: Colors.grey.shade800,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
