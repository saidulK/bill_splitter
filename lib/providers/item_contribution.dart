import 'package:flutter/material.dart';
import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/constants.dart';

class ItemContribuitionsProvider extends ChangeNotifier {
  List<Transaction> _itemContributions = [];

  List<Transaction> get itemContributions {
    return _itemContributions;
  }

  List<userData> get contributors {
    List<userData> userList = [];
    for (final transaction in _itemContributions) {
      userList.add(transaction.getUser());
    }
    return userList;
  }

  void set itemContributions(List<Transaction> itemContributions) {
    _itemContributions = itemContributions;
  }

  void clearContributions() {
    _itemContributions.clear();
    notifyListeners();
  }

  void addToCurrentContributions(Transaction T) {
    _itemContributions.add(T);
    notifyListeners();
  }

  void removeFromCurrentContributions(Transaction T) {
    _itemContributions.remove(T);
    notifyListeners();
  }

  void removeAtCurrentContributions(int index) {
    _itemContributions.removeAt(index);
    notifyListeners();
  }

  void addAmountAtCurrentContributions(int index, double amount) {
    _itemContributions[index].amount = amount;
    //notifyListeners();
  }

  void addForUserCurrentContributions(userData user, double value) {
    int index =
        _itemContributions.indexWhere((element) => element.user == user);

    _itemContributions[index] = Transaction(user, value);
    //notifyListeners();
  }

  Transaction getTransactionforUser(userData user) {
    int index =
        _itemContributions.indexWhere((element) => element.user == user);
    return _itemContributions[index];
  }

  Transaction getTransactionforindex(int index) {
    return _itemContributions[index];
  }
}
