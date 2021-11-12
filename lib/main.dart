import 'package:bill_splitter/models.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/homepage.dart';

void main() {
  runApp(
    StateWidget(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bill Splitter',
        home: Home(),
      ),
    ),
  );
}
