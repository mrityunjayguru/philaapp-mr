import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final String imageName;
  final String text;
  const IconTextWidget({required this.imageName,required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(imageName, width: 20,),
        SizedBox(width: 3,),
        Text(text, style: TextStyle(fontFamily: 'Lato', fontSize: 12),)
      ],
    );
  }
}
