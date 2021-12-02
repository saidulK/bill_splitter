import 'package:bill_splitter/providers/item_list.dart';
import 'package:bill_splitter/providers/user_list.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/constants.dart';
import 'package:provider/provider.dart';

class BillProvider extends ChangeNotifier {
  double _totalBill = 0;
  bool _isBilled = false;

  bool get isBilled {
    return _isBilled;
  }

  void set isBilled(bool billed) {
    _isBilled = billed;
  }

  double get totalBill {
    return _totalBill;
  }

  void calculateBill(BuildContext context) {
    List<userData> userList =
        Provider.of<UserListProvider>(context, listen: false).userList;
    List<itemData> itemList =
        Provider.of<ItemListProvider>(context, listen: false).itemList;

    for (var i = 0; i < userList.length; i++) {
      userList[i].bill = 0;
    }
    _totalBill = 0;
    _isBilled = true;
    for (final item in itemList) {
      for (final transaction in item.contributions) {
        transaction.user.bill += transaction.amount;
      }
      _totalBill += item.price;
      if (item.isInvalid()) _isBilled = false;
    }
  }
}
