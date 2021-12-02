import 'package:flutter/material.dart';
import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/constants.dart';

class ItemListProvider extends ChangeNotifier {
  List<itemData> _itemList = [];

  List<itemData> get itemList {
    return _itemList;
  }

  void addToItemList(itemData data, String tag) {
    _itemList.add(data);
    notifyListeners();
  }

  void updateItemAt(int index, itemData data, String tag) {
    _itemList[index].name = data.name;
    _itemList[index].price = data.price;
    _itemList[index].contributions = data.contributions;
    notifyListeners();
  }

  void removeAtItemList(int index, String tag) {
    _itemList.removeAt(index);
    notifyListeners();
  }
}
