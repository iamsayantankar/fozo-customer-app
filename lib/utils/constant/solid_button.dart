import 'package:fozo_customer_app/utils/constant/dimensions.dart';
import 'package:fozo_customer_app/utils/theme/theme_constants.dart';
import 'package:flutter/material.dart';

class SolidButton extends StatelessWidget {
  const SolidButton({
    Key? key,
    required this.onTap,
    this.width,
    this.height,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.boxShadow,
    this.color,
    this.auxWidget,
    required this.text,
  }) : super(key: key);

  final VoidCallback onTap;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double? borderRadius;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final Color? color;
  final Widget? auxWidget;
  final Text text;

  @override
  Widget build(BuildContext context) {
    double widthP = Dimensions.myWidthThis(context);
    double heightF = Dimensions.myHeightFThis(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: width ?? 393 * widthP,
        height: height ?? (54 * heightF),
        decoration: BoxDecoration(
          border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 2),
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? (10 * widthP)),
          ),
          boxShadow: boxShadow ?? [],
          color: color ?? solidButton(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                auxWidget ?? const SizedBox(),
                text,

              ],
            ),
          ],
        ),
      ),
    );
  }
}
