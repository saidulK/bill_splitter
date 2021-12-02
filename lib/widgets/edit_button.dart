import 'package:flutter/material.dart';
import 'package:bill_splitter/constants.dart';

class editButton extends StatelessWidget {
  Function onTap;
  double radius;

  editButton({required this.onTap, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: radius,
        backgroundColor: COLOR_EDIT_BLUE,
        child: InkWell(
          onTap: () => onTap(),
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ));
  }
}
