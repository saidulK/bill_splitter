import 'package:flutter/material.dart';
import 'package:bill_splitter/constants.dart';

class RectangleBanner extends StatelessWidget {
  final double height;
  final Widget child;
  final double h_offset;
  final double v_offset;
  final double h_margin;
  final double v_margin;
  final double borderRadius;
  final Color backgroundColor;

  RectangleBanner({
    required this.height,
    required this.borderRadius,
    this.backgroundColor = Colors.white,
    this.h_offset = 10,
    this.v_offset = 10,
    this.h_margin = 0,
    this.v_margin = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: h_offset, vertical: v_offset),
      margin: EdgeInsets.symmetric(horizontal: h_margin, vertical: v_margin),
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius))),
      child: child,
    );
  }
}
