// import 'package:fozo_customer_app/screens/utils/decoration/button_decoration.dart';
// import 'package:fozo_customer_app/utils/constant/dimensions.dart';
// import 'package:fozo_customer_app/utils/constant/text_styles.dart';
//
// import 'package:flutter/material.dart';
//
// class GradientButton extends StatefulWidget {
//   const GradientButton({
//     Key? key,
//     required this.onTap,
//     required this.width,
//     required this.height,
//     required this.text,
//     this.auxWidget,
//   }) : super(key: key);
//
//   final VoidCallback onTap;
//   final double? width;
//   final double? height;
//   final String text;
//   final Widget? auxWidget;
//
//
//   @override
//   State<GradientButton> createState() => _GradientButtonState();
// }
//
// class _GradientButtonState extends State<GradientButton> {
//   bool isBeingTapped = false;
//
//   @override
//   Widget build(BuildContext context) {
//     double widthP = Dimensions.myWidthThis(context);
//     double heightF = Dimensions.myHeightFThis(context);
//
//     return GestureDetector(
//       onTap: () {
//         widget.onTap();
//       },
//       child: Container(
//         width: widget.width ?? (181 * widthP),
//         height: widget.height ?? (54 * heightF),
//         decoration: buttonBoxDecoration(10.0*widthP),
//         child: Center(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 widget.text,
//                 style: CustomTextStyles.sfUITextMedium.copyWith(
//                   color: Colors.white,
//                   fontSize: (22 * widthP),
//                 ),
//               ),
//               widget.auxWidget ?? const SizedBox(width: 0,height: 0,),
//             ],
//           ),
//         ),
//       ),
//     );
//
//   }
// }
//
