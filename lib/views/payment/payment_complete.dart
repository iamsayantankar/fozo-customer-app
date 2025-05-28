import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../profile/past_order_screen.dart';

class PaymentComplete extends StatefulWidget {
  const PaymentComplete({super.key});

  @override
  State<PaymentComplete> createState() => _PaymentCompleteState();
}

class _PaymentCompleteState extends State<PaymentComplete> {
  @override
  void initState() {
    super.initState();

    // Navigate to Home screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PastOrderScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4ED6D), // Light green background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SVG Icon
              SvgPicture.asset(
                'assets/svg/success.svg', // Make sure this is the correct path
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 24),
              // Text
              const Text(
                'Order Confirmed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
