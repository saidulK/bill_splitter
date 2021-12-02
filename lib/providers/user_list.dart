import 'package:bill_splitter/providers/item_list.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/constants.dart';
import 'package:provider/provider.dart';

class UserListProvider extends ChangeNotifier {
  List<userData> _userList = [];

  List<userData> get userList {
    return _userList;
  }

  void addToUserList(userData data) {
    data.userColor =
        userColorList[(_userList.length + 1) % userColorList.length];
    _userList.add(data);
    notifyListeners();
  }

  void addUserPayment(userData user, double payment) {
    int index = _userList.indexWhere((element) => element == user);
    _userList[index].paid = payment;
    notifyListeners();
  }

  void removeAtUserList(BuildContext context, int index) {
    List<itemData> itemList =
        Provider.of<ItemListProvider>(context, listen: false).itemList;
    for (final item in itemList) {
      for (final contribution in item.contributions) {
        if (contribution.user == userList[index]) {
          item.contributions.remove(contribution);
          item.invalid = true;
          break;
        }
      }
    }
    _userList.removeAt(index);
    notifyListeners();
  }
}
