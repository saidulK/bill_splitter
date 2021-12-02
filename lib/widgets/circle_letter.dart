import 'package:flutter/material.dart';
import 'package:bill_splitter/constants.dart';

class CircleAvatarLetter extends StatelessWidget {
  Color backgroundColor;
  Color textColor;
  double radius;
  String letter;
  double fontSize;
  CircleAvatarLetter(
      {required this.backgroundColor,
      required this.radius,
      required this.letter,
      required this.fontSize,
      this.textColor = COLOR_WHITE});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      maxRadius: radius,
      child: Text(
        letter.replaceAll(' ', '')[0].toUpperCase(),
        style: TextStyle(
            fontSize: fontSize, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
