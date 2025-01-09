import 'package:flutter/material.dart';

import '../generated/assets.dart';
import '../themedata.dart';

class  AudioUnavailableWiget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
          color: ThemeClass.yellowColor,
          border: Border.all(color: ThemeClass.darkGreyColor),
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(right:10),
            decoration: BoxDecoration(
                color: ThemeClass.blackColor, shape: BoxShape.circle),
            child: Image.asset(Assets.imagesHeadphoneImg),
          ),
          Text("No audio available", style: TextStyle(
            color: ThemeClass.redColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lato',
            height: 1.5,
            fontSize: 15,
          )),
        ],
      )
    );

  }

}