import 'package:fozo_customer_app/utils/constant/dimensions.dart';
import 'package:fozo_customer_app/utils/constant/text_styles.dart';
import 'package:fozo_customer_app/utils/services/global.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GeneralRadioButton extends StatelessWidget {
  GeneralRadioButton({
    Key? key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.width,
  }) : super(key: key);

  String title;
  String? subtitle;
  bool isSelected;
  VoidCallback onTap;
  double width;

  @override
  Widget build(BuildContext context) {
    double widthP = Dimensions.myWidthThis(context);
    double heightF = Dimensions.myHeightFThis(context);


    return Container(
      decoration: BoxDecoration(
        color: myBoxColor(isSelected),
        borderRadius: BorderRadius.circular(10*widthP),
        border: Border.all(
            width: 0.6*widthP,
            color: myBoxBorderColor(isSelected)
        ),
      ),
      width: width,
      // height: height ?? (97 * heightP),
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: myUnselectedWidgetColor(),
        ),
        child: ListTile(
          dense: true,
          onTap: onTap,
          tileColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyles.sfUITextMedium.copyWith(
                      color: myPrimaryTextColor(isSelected),
                      fontSize: (16 * widthP),
                    ),
                  ),
                  if (subtitle == null) // Conditionally show the subtitle
                    SizedBox(
                      height: (3 * heightF),
                    ),
                  if (subtitle != null) ...[
                    SizedBox(
                      width: (width -100) * widthP,
                      child: Text(
                        subtitle!,
                        style: CustomTextStyles.sfUITextRegular.copyWith(
                          color: mySecondaryTextColor(isSelected),
                          fontSize: (14 * widthP),
                        ),
                      ),
                    ),
                  ],


                ],
              ),
              Radio<bool>(
                activeColor: Colors.white,
                value: isSelected,
                groupValue: true,
                onChanged: (_) {
                  onTap();
                },
                // activeColor: activeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color myBoxColor(bool active) {

    final brightness =
        MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
    if (brightness == Brightness.dark && active==true) {
      return const Color(0xFFAB11D4);
    }else if (brightness == Brightness.dark && active==false) {
      return const Color.fromRGBO(61, 0, 76, 0.63);
    }else if (brightness == Brightness.light && active==true) {
      return const Color.fromRGBO(69, 21, 81, 0.10);
    }else if (brightness == Brightness.light && active==false) {
      return const Color(0xFFFFFDFB);
    }
    return const Color(0xFFFFFFFF);

  }

  myBoxBorderColor(bool active) {
    final brightness =
        MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
    if (brightness == Brightness.dark && active==true) {
      return const Color.fromRGBO(200, 7, 248, 0.67);
    }else if (brightness == Brightness.dark && active==false) {
      return const Color.fromRGBO(200, 7, 248, 0.37);
    }else if (brightness == Brightness.light && active==true) {
      return const Color(0xFF451551);
    }else if (brightness == Brightness.light && active==false) {
      return const Color(0xFFDDDDDD);
    }
    return const Color(0xFFFFFFFF);
  }


  myPrimaryTextColor(bool active) {
    final brightness =
        MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
    if (brightness == Brightness.dark && active==true) {
      return const Color(0xFFFFFFFF);
    }else if (brightness == Brightness.dark && active==false) {
      return const Color(0xFFFFFFFF);
    }else if (brightness == Brightness.light && active==true) {
      return const Color(0xFF451551);
    }else if (brightness == Brightness.light && active==false) {
      return const Color(0xFF252525);
    }
    return const Color(0xFFFFFFFF);
  }


  mySecondaryTextColor(bool active) {
    final brightness =
        MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
    if (brightness == Brightness.dark && active==true) {
      return const Color.fromRGBO(255, 253, 251, 0.71);
    }else if (brightness == Brightness.dark && active==false) {
      return const Color.fromRGBO(180, 175, 175, 0.85);
    }else if (brightness == Brightness.light && active==true) {
      return const Color.fromRGBO(69, 21, 81, 0.50);
    }else if (brightness == Brightness.light && active==false) {
      return const Color(0xFF868686);
    }
    return const Color(0xFFFFFFFF);
  }

  myUnselectedWidgetColor() {
    final brightness =
        MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
    if (brightness == Brightness.dark ) {
      return const Color(0xFFC807F8).withOpacity(0.37);
    }else  {
      return const Color(0xFFDDDDDD);
    }
  }
}
