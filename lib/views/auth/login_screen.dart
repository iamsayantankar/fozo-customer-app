import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constant/dimensions.dart';
import '../../utils/services/auth.dart';
import '../../widgets/custom_button_widget.dart';
import '../home/home_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int currentIndex = 0;
  final List<Map<String, dynamic>> content = [
    {
      'title': 'Discover Restaurants',
      'description':
          'Find Surprise Bags from your favorite restaurants at up to 50% OFF near you.',
      'image': 'assets/png/photo1.png',
    },
    {
      'title': 'Reserve your meal bag',
      'description':
          'Secure your meal by reserving a Surprise Bag. Get ready for a delicious surprise.',
      'image': 'assets/png/photo2.png',
    },
    {
      'title': 'Get It Delivered & Enjoy',
      'description':
          'Sit back and relax—your meal is on the way! Enjoy great food while saving money & fresh food.',
      'image': 'assets/png/photo3.png',
    },
  ];

  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);

    _timer = Timer.periodic(Duration(milliseconds: 1500), (Timer timer) {
      if (currentIndex < content.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      _pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double widthP = Dimensions.myWidthThis(context);
    double heightP = Dimensions.myHeightThis(context);

    // final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Top Section (Skip Button + Illustration)
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEFFA9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: widthP * 75,
                          height: heightP * 35,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 14),
                          decoration: BoxDecoration(
                            color: Color(0xFF0732280F)
                                .withOpacity(0.2), // Change the color as needed
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FozoHomeScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Skip',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          itemCount: content.length,
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenWidth * 0.38,
                                  height: screenWidth * 0.38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image:
                                          AssetImage(content[index]['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  content[index]['title']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05),
                                  child: Text(
                                    content[index]['description']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                              ],
                            );
                          },
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(content.length, (indicatorIndex) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: indicatorIndex == currentIndex ? 16 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: indicatorIndex == currentIndex
                                      ? Color(0xFF3D914F)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40 * heightP,
                      )
                    ],
                  ),
                ),
              ],
            ),

            /// Phone Input Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Login or sign up",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),

                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text("+91", style: TextStyle(fontSize: 16.sp)),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              hintText: "Enter phone number",
                              border: InputBorder.none,
                              counterText: "", // Remove the default counter
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12.w),
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            onChanged: (value) {
                              setState(() {
                                _phoneNumber = value.trim();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// Show Progress Indicator When Sending OTP

                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      // Minimal check: phone length should be 10
                      if (_phoneNumber.length == 10) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPVerificationScreen(
                              phoneNumber: _phoneNumber,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Enter a valid 10-digit number")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            /// Social Login Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text("Or continue with",
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  // TODO: Add social login buttons here
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AuthMethods().signInWithGoogle(context);
                          // Add your function here
                        },
                        child: SvgPicture.asset(
                          'assets/svg/google_log_in.svg',
                          height: 56,
                          width: 56,
                        ),
                      ),
                      SizedBox(width: 40.w),
                      GestureDetector(
                        onTap: () {
                          AuthMethods().signInWithGoogle(context);
                          // Add your function here
                        },
                        child: SvgPicture.asset(
                          'assets/svg/apple_log_in.svg',
                          height: 56,
                          width: 56,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            /// Terms and Conditions
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    "By continuing you agree to our",
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                          ),
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
    );
  }
}
