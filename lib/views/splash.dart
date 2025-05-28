import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/helper/shared_preferences_helper.dart';
import 'auth/information_screen.dart';
import 'auth/login_screen.dart';
import 'auth/map_location_screen.dart';
import 'home/home_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    _getData();
  }

  Future<void> _getData() async {
    await Future.delayed(Duration(seconds: 2));

    // Retrieve the stored user email to check login status
    String userLookup =
        await SharedPreferencesHelper.getString("userLookup") ?? "";

    if (userLookup.isNotEmpty && userLookup != "") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FozoHomeScreen(),
        ),
      );
    } else {
      // Retrieve the stored user email to check login status
      String? jsonString = await SharedPreferencesHelper.getString("loginData");

      if (jsonString != null) {
        Map getData = jsonDecode(jsonString);

        if (getData["pageName"] == "InformationScreen") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InformationScreen(),
            ),
          );
          return;
        }

        if (getData["pageName"] == "AddDeliveryLocationScreen") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddDeliveryLocationScreen(),
            ),
          );
          return;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Back not allowed')),
        );
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD4ED6D), // ✅ Scaffold background
        body: SafeArea(
          child: Container(
            color: const Color(0xFFD4ED6D), // ✅ Container background
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/fozo_logo.svg',
                width: 153,
                height: 60,
                color: Color(0xFF073228), // ✅ Set SVG color
              ),
            ),
          ),
        ),
      ),
    );
  }
}
