import 'package:flutter/material.dart';
import 'package:bill_splitter/constants.dart';

class crossButton extends StatelessWidget {
  Function onTap;
  double radius;

  crossButton({required this.onTap, required this.radius});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: CircleAvatar(
          radius: radius,
          backgroundColor: COLOR_RED,
          child: Icon(
            Icons.close,
            color: Colors.white,
          )),
    );
  }
}
