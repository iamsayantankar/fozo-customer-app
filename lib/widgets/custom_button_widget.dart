import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final Color? textColor;
  final double? fontSize;
  final double? height;
  final double? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonColor,
    this.textColor = Colors.white,
    this.fontSize = 15,
    this.height = 50,
    this.borderRadius = 17,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? AppColor.buttonColor, // Default color
        minimumSize: Size(double.infinity, height!.h), // Responsive height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadius!.r), // Responsive border radius
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize!.sp, // Responsive font size
          color: textColor,
        ),
      ),
    );
  }
}
