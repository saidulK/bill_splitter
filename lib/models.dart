import 'package:flutter/material.dart';

class contribution {
  Map contributionMap = {};

  void addContribution(String contributor, String acceptor, double amount) {}
}

class userData {
  String name;
  double bill;
  double paid;
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

  itemData(
      {required this.name, required this.price, required this.contributions});
}

class StateWidget extends StatefulWidget {
  final Widget child;

  StateWidget({Key? key, required this.child}) : super(key: key);

  @override
  StateWidgetState createState() => StateWidgetState();
}

class StateWidgetState extends State<StateWidget> {
  List<userData> userList = [];
  List<itemData> itemList = [];

  void addToUserList(userData data) {
    setState(() {
      userList.add(data);
    });
  }

  void removeAtUserList(int index) {
    setState(() {
      userList.removeAt(index);
    });
  }

  void addToItemList(itemData data) {
    setState(() {
      itemList.add(data);
    });
  }

  void removeAtItemList(int index) {
    setState(() {
      itemList.removeAt(index);
    });
  }

  void calculateBill() {
    setState(() {
      for (final item in itemList) {
        for (final transaction in item.contributions) {
          transaction.user.bill += transaction.amount;
        }
      }
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
  bool updateShouldNotify(StateInheritedWidget oldWidget) => true;
  //oldWidget.stateWidget.dataList.length == stateWidget.dataList.length;
}
