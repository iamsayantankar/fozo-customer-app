import 'package:flutter/material.dart';

class Dimensions {
  static double myWidthThis(BuildContext context) {
    return MediaQuery.of(context).size.width / 390;
  }

  static double myHeightThis(BuildContext context) {
    return MediaQuery.of(context).size.height / 844;
  }

  // TODO: Size with out status-bar and navigation-bar
  static double myHeightFThis(BuildContext context) {
    return (MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.bottom -
            MediaQuery.of(context).padding.top) /
        852;
  }
}
