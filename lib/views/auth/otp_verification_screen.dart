import 'dart:async';
import 'dart:convert';

import 'package:another_telephony/telephony.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

import '../../core/constants/colour_constants.dart';
import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/http/api.dart';
import '../../widgets/custom_button_widget.dart';
import '../home/home_screen.dart';
import 'information_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber; // <-- phone from OTP

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// 🔹 Firebase verification properties
  String _otpValue = '';
  String _verificationId = '';
  String _uid = '';
  bool _isSendingOTP = false;
  bool _isVerifyingOTP = false;
  bool _isResendAvailable = false;
  int _resendTimer = 30;
  Timer? _timer;
  final Telephony telephony = Telephony.instance;

  /// 🔹 Getters
  // String get verificationId => _verificationId;
  // String get uid => _uid;
  // bool get isSendingOTP => _isSendingOTP;
  // bool get isVerifyingOTP => _isVerifyingOTP;
  // int get resendTimer => _resendTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkExistingUser();
  }

  Future<void> checkExistingUser() async {
    // final user = _firebaseAuth.currentUser;
    // if (user != null) {
    //   // User is already logged in => go to Home
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const FozoHomeScreen()),
    //   );
    // } else {
    sendOTP();
    // }
  }

  /// 🔹 Starts the Resend OTP Timer (e.g., 30s)
  void _startResendTimer() {
    _isResendAvailable = false;
    _resendTimer = 30;
    setState(() {});

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        setState(() {});
      } else {
        _isResendAvailable = true;
        setState(() {});
        timer.cancel();
      }
    });
  }

  /// 🔹 Sends OTP to the entered phone number
  Future<void> sendOTP() async {
    try {
      // Ensure +91 prefix
      var formattedNumber = widget.phoneNumber;
      if (!formattedNumber.startsWith("+")) {
        formattedNumber = "+91$formattedNumber";
      }

      _isSendingOTP = true;
      setState(() {});

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          listenToIncomingSMS();
          // Auto-verification case
          final userCredential =
              await _firebaseAuth.signInWithCredential(credential);

          final user = _firebaseAuth.currentUser;
          if (user != null) {
            final idToken = await userCredential.user?.getIdToken() ?? '';

            _uid = user.uid;

            final res = await ApiService.getRequest(
                "auth/lookup?contactNumber=${widget.phoneNumber}");

            if (res["user"]?["role"] == "Customer") {
              String actionString = jsonEncode(res);
              await SharedPreferencesHelper.saveString(
                  'userLookup', actionString);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FozoHomeScreen()),
              );
            } else {
              String jsonString = jsonEncode({
                "pageName": "InformationScreen",
                "phoneNumber": widget.phoneNumber,
                "firebaseUid": _uid,
                "idToken": idToken
              });

              await SharedPreferencesHelper.saveString("loginData", jsonString);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InformationScreen(),
                ),
              );
            }
          }

          _isSendingOTP = false;
          setState(() {});
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSendingOTP = false;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Phone verification failed")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          listenToIncomingSMS();
          _verificationId = verificationId;
          _isSendingOTP = false;
          setState(() {});
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _isSendingOTP = false;
      setState(() {});
      debugPrint("Error sending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending OTP. Please try again.")),
      );
    }
  }

  /// 🔹 Verifies OTP entered by the user
  Future<void> verifyOTP() async {
    try {
      _isVerifyingOTP = true;
      setState(() {});

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpValue,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final idToken = await userCredential.user?.getIdToken() ?? '';

      _uid = userCredential.user?.uid ?? '';
      _isVerifyingOTP = false;
      setState(() {});
      print("userCredential.user");
      print(userCredential.user);

      if (_uid.isNotEmpty) {
        final res = await ApiService.getRequest(
            "auth/lookup?contactNumber=${widget.phoneNumber}");
        // final res = await ApiService.getRequest("auth/lookup?contactNumber=4444444");
        print(res);

        print(res["user"]?["role"]);
        if (res["user"]?["role"] == "Customer") {
          // Convert JSON to string and save
          String actionString = jsonEncode(res);
          await SharedPreferencesHelper.saveString(
              'userLookup', actionString); // Save a string value

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FozoHomeScreen(),
            ),
          );
        } else {
          String jsonString = jsonEncode({
            "pageName": "InformationScreen",
            "phoneNumber": widget.phoneNumber,
            "firebaseUid": _uid,
            "idToken": idToken
          });

          await SharedPreferencesHelper.saveString("loginData", jsonString);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InformationScreen(),
            ),
          );
        }
      }

      return;
    } catch (e) {
      _isVerifyingOTP = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  /// 🔹 Resend OTP after timer ends
  Future<void> resendOTP() async {
    if (!_isResendAvailable) return;
    await sendOTP();
  }

  void listenToIncomingSMS() {
    print("Listening to sms.");
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Handle message
          print("sms received : ${message.body}");
          // verify if we are reading the correct sms or not

          if (message.body!.contains("verification code")) {
            String otpCode = message.body!.substring(0, 6);
            setState(() {
              _otpValue = otpCode;
              if (_otpValue.length == 6) {
                verifyOTP();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Enter a valid 6-digit OTP"),
                  ),
                );
              }
            });
          }
        },
        listenInBackground: false);
  }

  /// 🔹 Dispose timer when the provider is destroyed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "OTP Verification",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Center(
          child: SingleChildScrollView(
            child: _isSendingOTP || _isVerifyingOTP
                ? Container(
                    child: Lottie.asset('assets/json/loading.json'),
                  )
                : Column(
                    children: [
                      /// Title & Subtitle
                      Text(
                        "We've sent you an OTP",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "We sent an OTP to your mobile number\n+91-${widget.phoneNumber}",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),

                      /// OTP Input
                      Pinput(
                        hapticFeedbackType: HapticFeedbackType.mediumImpact,
                        // androidSmsAutofillMethod: AndroidSmsAutofillMethod
                        //     .smsRetrieverApi, // 👈 this enables auto-fill prompt on Android
                        length: 6,
                        keyboardType: TextInputType.number,
                        defaultPinTheme: PinTheme(
                          width: 60.w,
                          height: 60.h,
                          textStyle: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _otpValue = value.trim();
                          });
                        },
                      ),

                      SizedBox(height: 20.h),

                      /// Resend OTP Timer / Button
                      _isResendAvailable
                          ? TextButton(
                              onPressed: () => resendOTP(),
                              child: Text(
                                "Did't get the OTP? Resend SMS",
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.blue),
                              ),
                            )
                          : Text(
                              "Did't get the OTP? Try again in $_resendTimer seconds",
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.grey),
                            ),
                      SizedBox(height: 30.h),

                      /// Continue Button
                      _isVerifyingOTP
                          ? const CircularProgressIndicator()
                          : _otpValue.length == 6
                              ? CustomButton(
                                  text: "Continue",
                                  onPressed: () {
                                    if (_otpValue.length == 6) {
                                      verifyOTP();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text("Enter a valid 6-digit OTP"),
                                        ),
                                      );
                                    }
                                  },
                                )
                              : SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
