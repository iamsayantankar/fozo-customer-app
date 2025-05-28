import 'package:fozo_customer_app/utils/services/global.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(brightness: Brightness.light);

ThemeData darkTheme = ThemeData(brightness: Brightness.dark);

String assetsPath() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return "assets/images/dark/";
  } else {
    return "assets/images/light/";
  }
}

String iconAssetsPath() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return "assets/images/icon/dark/";
  } else {
    return "assets/images/icon/light/";
  }
}

Brightness myPhoneThemeTypeOpposite() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return Brightness.light;
  } else {
    return Brightness.dark;
  }
}

Color customSystemNavigationBarColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF451551);
  } else {
    return const Color(0xFFF8F4EF);
  }
}

Color customHomeSystemNavigationBarColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const  Color(0xFF22002B);
  } else {
    return const Color(0xFFFFFFFF);
  }
}

Color customBoxShadowNavigationColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const  Color(0xFF6F2776).withOpacity(0.53);
  } else {
    return const Color.fromRGBO(0, 0, 0, 0.30);
  }
}

Color customUnselectedItemColorNavigationColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return Color(0xFFBB00CC);
  } else {
    return Color(0xFFA400B3);
  }
}

BoxDecoration boxDecoration() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  if (brightness == Brightness.dark) {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(
          "assets/images/dark/bg.png",
        ),
        fit: BoxFit.cover,
      ),
    );
  } else {
    return const BoxDecoration(
      color: Color(0xFFFFFCF9),
    );
  }
}

Color customStatusNavigationBarColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF451551);
  } else {
    return const Color(0xFFF8F4EF);
  }
}

Color textPrimaryColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return Colors.white;
  } else {
    return const Color(0xFF252525);
  }
}

Color textSecondaryColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF868686);
  } else {
    return const Color(0xFFB4AFAF);
  }
}

Color textChatPrimaryColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return Colors.white;
  } else {
    return const Color(0xFF000000);
  }
}

Color solidButton() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF3C024B);
  } else {
    return const Color(0xFFE2DBE5);
  }
}

Color solidButtonTextColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFFCF4F4);
  } else {
    return const Color(0xFF451551);
  }
}

Color checkBoxColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF6B4973);
  } else {
    return const Color(0xFF451551);
  }
}

Color slider() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF4B2256);
  } else {
    return const Color(0xFFE3D9E5);
  }
}

Color calendar() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF393939);
  } else {
    return const Color(0xFFFFFCFF);
  }
}

Color calendarSurface() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF531961);
  } else {
    return const Color(0xFF451551);
  }
}

Color photosBackground() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF4A3F4D);
  } else {
    return const Color(0xFFF5F5F5);
  }
}

Color radioButtonSelcted() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFC807F8);
  } else {
    return const Color(0xFF451551);
  }
}

Color radioButtonNotSelcted() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF3D004C);
  } else {
    return const Color(0xFFFFFDFB);
  }
}

Color nestedRadioButtonNotSelcted() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF22002B);
  } else {
    return const Color(0xFFFFFDFB);
  }
}

Color nestedRadioButtonSelcted() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF694971);
  } else {
    return const Color(0xFFDACED9);
  }
}

Color borderColorRadio() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFC807F8);
  } else {
    return const Color(0xFFFFFDFB);
  }
}

Color borderColorRadioDate() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFC807F8);
  } else {
    return const Color(0xFF451551);
  }
}

Color inactiveRadio() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFC708F6);
  } else {
    return const Color(0xFFDCDDDC);
  }
}

Color activeWomanButton() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFC807F8);
  } else {
    return const Color(0xFF451551);
  }
}

Color chooseTypeTile() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFAB11D4);
  } else {
    return const Color(0xFFECE5EF);
  }
}

Color chooseTypeText() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFFFFDFB);
  } else {
    return const Color(0xFF987C9F);
  }
}

Color textFieldBorderColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF5F0377);
  } else {
    return const Color(0xFFDCDCDD);
  }
}

Color vinetaTextStyleColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFFFFFFF);
  } else {
    return const Color(0xFF5B5B5B);
  }
}

Color takePhotoCardColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF3C024B);
  } else {
    return const Color(0xFFFFFFFF);
  }
}

Color inactiveColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF8C6E95);
  } else {
    return const Color(0xFFECE4EF);
  }
}

Color activeColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF491B54);
  } else {
    return const Color(0xFF754E7C);
  }
}


Color borderShadowColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF7E1199);
  } else {
    return const Color(0xFFA9A9A9);
  }
}
Color rareUseButtonBackground() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFF2EA12);
  } else {
    return const Color(0xFFDED60C);
  }
}

Color textSelectColorRadio() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFFFFDFB);
  } else {
    return const Color(0xFFC807F8);

  }
}
Color textUnselectedColorRadio() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFC807F8);
  } else {
    return const Color(0xFF000000);
  }
}
Color textMatchPrimaryColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFA400B3);
  } else {
    return const Color(0xFF9E00AC);
  }
}
Color textCustomColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFFFE1E1);
  } else {
    return const Color(0xFFEE1818);
  }
}

Color textLanguagesColorRadio() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFFFFFFFF);

  } else {
    return const Color(0xFF7A0385);
  }
}

Color drawerBackgroundColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF252525);
  } else {

    return Colors.white;
  }
}

Color dotsIndicatorColorActive() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return Colors.white;
  } else {

    return Color(0xFF26032F);
  }
}
Color dotsIndicatorColorNotActive() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return Color(0xFFCDCDCD).withOpacity(0.32);
  } else {

    return  Color(0xFF323232).withOpacity(0.32);
  }
}
Color backgroundButtonColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return  Color.fromRGBO(199, 27, 242, 0.77);
  } else {

    return  Color.fromRGBO(187, 13, 231, 0.73);
  }
}
Gradient forShadowButton() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return   LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(200, 73, 195, 0.17),
        Color.fromRGBO(200, 73, 195, 0.17),
      ],
      stops: [0.1664, 0.9906], // Gradient stops
    );
  } else {

    return   LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(200, 73, 195, 0.17),
        Color.fromRGBO(214, 74, 208, 0.14),
      ],
      stops: [0.1664, 0.9906], // Gradient stops
    );
  }
}

Color backgroundLinearProgressBarColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return  Color(0xFF561A65);
  } else {

    return  Color(0xFFD9D9D9);
  }
}
Color ColorLinearProgressBarColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return  Color(0xFF9026AB);
  } else {

    return  Color(0xFF7F2196);
  }
}
LinearGradient textOnlyForLevelUPColor() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return  LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF780196), // Start color
        Color.fromRGBO(202, 197, 203, 0.60), // End color with opacity
      ],
    );
  } else {

    return  LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF451551),
        Color(0xFF451551),
      ],
    );
  }
}
Color backGroundColorMarketing() {
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // if(Theme.of(GlobalVariable.navState.currentContext!).brightness==Brightness.dark){
  if (brightness == Brightness.dark) {
    return const Color(0xFF3C024B);
  } else {
    return  Colors.white;
  }
}


