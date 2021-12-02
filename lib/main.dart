import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ItemListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ItemContribuitionsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BillProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bill Splitter',
        home: Home(),
      ),
    ),
  );
}
