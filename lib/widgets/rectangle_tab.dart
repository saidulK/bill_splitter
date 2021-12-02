import 'package:flutter/material.dart';
import 'package:bill_splitter/constants.dart';

class rectangleTab extends StatelessWidget {
  final double height;
  final Color shadowColor;
  final Widget child;
  final double h_offset;
  final double v_offset;
  final double h_margin;
  final double v_margin;
  final double borderRadius;
  final Color backgroundColor;

  rectangleTab({
    required this.height,
    required this.borderRadius,
    this.backgroundColor = Colors.white,
    this.shadowColor = COLOR_SHADOW_GREY,
    this.h_offset = 10,
    this.v_offset = 10,
    this.h_margin = 0,
    this.v_margin = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h_offset, vertical: v_offset),
      margin: EdgeInsets.symmetric(horizontal: h_margin, vertical: v_margin),
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.2), //Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 12, // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}
