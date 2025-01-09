import 'package:flutter/material.dart';

class ThemeClass {
  static final Color redColor = Color(0xFFCD001C);
  static final Color lightgreyColor = Color(0xFFf2f2f2);
  static final Color greyColor = Color(0xFF707070);
  static final Color darkGreyColor = Color(0xFF646464);
  static final Color whiteColor = Color(0xFFFFFFFF);
  static final Color blackColor = Color(0xFF000000);
  // static final Color = Color(0xFF000000);

  static final Color yellowColor = Color(0xFFFFEE00);
  static final Color skyblueColor = Color(0xFF2FA4E2);
  static final Color orangeColor = Color(0xFFF49024);
  static final Color prupolColor = Color(0xFFC81C8E);

  static final Color greenColor = Color(0xFF6EBC44);

  static final themeData = ThemeData(
      primaryColor: ThemeClass.yellowColor,
      fontFamily: 'Lato',
      splashColor: ThemeClass.redColor.withOpacity(0.2));
}
