import 'package:bill_splitter/constants.dart';
import 'package:flutter/material.dart';

class contribution {
  Map contributionMap = {};

  void addContribution(String contributor, String acceptor, double amount) {}
}

class userData {
  String name;
  double bill;
  double paid;
  List<Color> userColor = [Color(0xFF383E56), Color(0xFFF69E7B)];
  List<Transaction> contributedList = [];
  List<Transaction> receivedList = [];
  userData(Key? key, this.name, this.bill, this.paid);

  double getSurplus() {
    return paid - bill;
  }

  void addToBill(double amount) {
    bill += amount;
  }

  void addContribution(Transaction t) {
    contributedList.add(t);
  }

  void removeContribution(Transaction t) {
    contributedList.remove(t);
  }

  void removeContributionAt(int index) {
    contributedList.removeAt(index);
  }
}

class Transaction {
  userData user;
  double amount;
  Transaction(this.user, this.amount);

  userData getUser() {
    return user;
  }

  double getAmount() {
    return amount;
  }

  List getInfo() {
    return [user, amount];
  }
}

class itemData {
  String name;
  double price;
  List<Transaction> contributions;
  bool _invalid = false;

  itemData(
      {required this.name, required this.price, required this.contributions});

  bool isInvalid() {
    return _invalid;
  }

  void set invalid(invalid) {
    _invalid = invalid;
  }

  void checkValid() {
    double total = 0;
    for (final t in contributions) {
      total += t.amount;
    }
    _invalid = (total != price);
  }
}

/* class StateWidget extends StatefulWidget {
  final Widget child;

  StateWidget({Key? key, required this.child}) : super(key: key);

  @override
  StateWidgetState createState() => StateWidgetState();
}

class StateWidgetState extends State<StateWidget> {
  List<userData> userList = [];
  List<itemData> itemList = [];

  bool isBilled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitialState();
  }

  void setInitialState() {
    userList = [
      userData(UniqueKey(), "Name1", 0, 0),
      userData(UniqueKey(), "Name2", 0, 0),
      userData(UniqueKey(), "Name3", 0, 0),
      userData(UniqueKey(), "Name4", 0, 0),
      userData(UniqueKey(), "Name5", 0, 0),
      userData(UniqueKey(), "Name6", 0, 0),
      userData(UniqueKey(), "Name7", 0, 0),
    ];
    for (var i = 0; i < userList.length; i++) {
      userList[i].userColor = userColorList[i % userColorList.length];
    }
    itemList = [
      itemData(name: "item1", price: 1000, contributions: [
        Transaction(userList[0], 500),
        Transaction(userList[1], 500)
      ]),
      itemData(name: "item2", price: 1000, contributions: [
        Transaction(userList[0], 500),
        Transaction(userList[2], 500),
        Transaction(userList[3], 500)
      ]),
      itemData(name: "item3", price: 1000, contributions: [
        Transaction(userList[0], 500),
        Transaction(userList[4], 500),
        Transaction(userList[5], 500)
      ]),
      itemData(name: "item4", price: 1000, contributions: [
        Transaction(userList[6], 500),
        Transaction(userList[0], 500)
      ]),
      itemData(name: "item5", price: 1000, contributions: [
        Transaction(userList[0], 500),
        Transaction(userList[3], 500)
      ]),
      itemData(name: "item6", price: 1000, contributions: [
        Transaction(userList[0], 500),
        Transaction(userList[2], 500),
        Transaction(userList[3], 500)
      ]),
      itemData(name: "item7", price: 1000, contributions: [
        Transaction(userList[0], 500),
        Transaction(userList[2], 500),
        Transaction(userList[3], 500)
      ]),
    ];
    calculateBill();
  }

  void addToUserList(userData data) {
    setState(() {
      data.userColor =
          userColorList[(userList.length + 1) % userColorList.length];
      userList.add(data);
      print("state widget updated user add");
    });
  }

  void addUserPayment(userData user, double payment) {
    setState(() {
      int index = userList.indexWhere((element) => element == user);
      userList[index].paid = payment;
      print("state widget updated user payment add");
    });
  }

  void removeAtUserList(int index) {
    setState(() {
      for (final item in itemList) {
        for (final contribution in item.contributions) {
          if (contribution.user == userList[index]) {
            item.contributions.remove(contribution);
            break;
          }
        }
      }
      userList.removeAt(index);
      print("state widget updated user remove");
    });
  }

  void addToItemList(itemData data, String tag) {
    setState(() {
      itemList.add(data);
      print("state widget updated " + tag);
    });
  }

  void updateItemAt(int index, itemData data, String tag) {
    setState(() {
      itemList[index].name = data.name;
      itemList[index].price = data.price;
      itemList[index].contributions = data.contributions;
      print("state widget updated " + tag);
    });
  }

  void removeAtItemList(int index, String tag) {
    setState(() {
      itemList.removeAt(index);
      print("state widget updated " + tag);
    });
  }

  void calculateBill() {
    setState(() {
      for (var i = 0; i < userList.length; i++) {
        userList[i].bill = 0;
      }
      for (final item in itemList) {
        for (final transaction in item.contributions) {
          transaction.user.bill += transaction.amount;
        }
      }
      this.isBilled = true;
      print("state widget updated billed");
    });
  }

  @override
  Widget build(BuildContext context) {
    return StateInheritedWidget(
      //userList: dataList,
      stateWidget: this,
      child: widget.child,
    );
  }
}

class StateInheritedWidget extends InheritedWidget {
  //final List<userData> userList;
  final StateWidgetState stateWidget;

  const StateInheritedWidget(
      {Key? key,
      //required this.userList,
      required this.stateWidget,
      required Widget child})
      : super(key: key, child: child);

  static StateWidgetState of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<StateInheritedWidget>()!
      .stateWidget;

  @override
  bool updateShouldNotify(StateInheritedWidget oldWidget) => true;
  //oldWidget.stateWidget.dataList.length == stateWidget.dataList.length;
}

class contributionStateWidget extends StatefulWidget {
  final Widget child;

  contributionStateWidget({Key? key, required this.child}) : super(key: key);

  @override
  contributionWidgetState createState() => contributionWidgetState();
}

class contributionWidgetState extends State<contributionStateWidget> {
  List<Transaction> currentContributions = [];

  void addToCurrentContributions(Transaction T) {
    currentContributions.add(T);
  }

  void clearCurrentContributions() {
    currentContributions.clear();
  }

  void removeFromCurrentContributions(Transaction T) {
    currentContributions.remove(T);
  }

  void removeAtCurrentContributions(int index) {
    currentContributions.removeAt(index);
  }

  void addAmountAtCurrentContributions(int index, double amount) {
    currentContributions[index].amount = amount;
  }

  void addForUserCurrentContributions(userData user, double value) {
    int index =
        currentContributions.indexWhere((element) => element.user == user);

    currentContributions[index] = Transaction(user, value);
  }

  Transaction getTransactionforUser(userData user) {
    int index =
        currentContributions.indexWhere((element) => element.user == user);
    return currentContributions[index];
  }

  Transaction getTransactionforindex(int index) {
    return currentContributions[index];
  }

  @override
  Widget build(BuildContext context) {
    return contributionStateInheritedWidget(
      //userList: dataList,
      stateWidget: this,
      child: widget.child,
    );
  }
}

class contributionStateInheritedWidget extends InheritedWidget {
  //final List<userData> userList;
  final contributionWidgetState stateWidget;

  const contributionStateInheritedWidget(
      {Key? key,
      //required this.userList,
      required this.stateWidget,
      required Widget child})
      : super(key: key, child: child);

  static contributionWidgetState of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<contributionStateInheritedWidget>()!
      .stateWidget;

  @override
  bool updateShouldNotify(contributionStateInheritedWidget oldWidget) => true;
  //oldWidget.stateWidget.dataList.length == stateWidget.dataList.length;
}
*/