import 'package:bill_splitter/constants.dart';
import 'package:bill_splitter/itempage.dart';
import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/widgets.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int current_page_index = 0;
  String title = "BILL SPLITTER";
  PageController pageController = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: COLOR_BLACK,
          title: Text(
            title,
            style: TextStyle(color: Colors.white70),
          ),
          centerTitle: true,
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (newIndex) {
            setState(() {
              current_page_index = newIndex;
              switch (current_page_index) {
                case 0:
                  title = "BILL SPLITTER";
                  break;
                case 1:
                  title = "ITEM LIST";
                  break;
              }
            });
          },
          children: [userList(), ItemPage(pageController: pageController)],
          physics: BouncingScrollPhysics(),
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: current_page_index,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
            BottomNavigationBarItem(
                icon: Icon(Icons.food_bank), label: 'Items'),
          ],
          onTap: (newIndex) {
            pageController.animateToPage(newIndex,
                duration: Duration(milliseconds: 100), curve: Curves.ease);
          },
        ),
      ),
    );
  }
}

class userList extends StatefulWidget {
  final String title = "BILL SPLITTER";
  const userList({Key? key}) : super(key: key);

  @override
  userListState createState() => userListState();
}

class userListState extends State<userList> with AutomaticKeepAliveClientMixin {
  void onFloatingButtonPressed(BuildContext context) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent, child: AddUserCard());
        });

    if (result != null && result != "" && result != " ") {
      StateInheritedWidget.of(context)
          .addToUserList(userData(UniqueKey(), result, 0, 0));
    }
  }

  void onCalculatePressed() {}

  void removeItem(BuildContext context, int index) {
    StateInheritedWidget.of(context).removeAtUserList(index);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    List<userData> nameList = StateInheritedWidget.of(context).userList;

    double listHeight = screenHeight * 0.7;
    double rowHeight = listHeight / 5;

    double topPadding = 0;
    //add in inherited widget
    bool isBilled = StateInheritedWidget.of(context).isBilled;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Container(
            height: listHeight - topPadding,
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return UserTab(
                      key: UniqueKey(),
                      user: nameList[index],
                      deleteUser: () => removeItem(context, index),
                      rowHeight: rowHeight);
                },
                itemCount: nameList.length),
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                heroTag: 'Transactions',
                backgroundColor: COLOR_BLACK,
                onPressed: onCalculatePressed,
                label: Text('Transactions', style: TextStyle(fontSize: 20)),
              ),
              FloatingActionButton(
                heroTag: 'Add',
                onPressed: () => onFloatingButtonPressed(context),
                backgroundColor: COLOR_BLACK,
                elevation: 10,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class UserTab extends StatefulWidget {
  final userData user;
  final VoidCallback deleteUser;
  final double rowHeight;
  const UserTab(
      {Key? key,
      required this.user,
      required this.deleteUser,
      required this.rowHeight})
      : super(key: key);
  @override
  UserTabState createState() => UserTabState();
}

class UserTabState extends State<UserTab> {
  var _showCancelButton = false;

  void enableCancelButton() {
    setState(() {
      _showCancelButton = true;
    });
  }

  void showUserPage(userData user) async {
    var result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => userPage(user: user)));
    if (result != null) {
      StateInheritedWidget.of(context).addUserPayment(user, result);
    } else {
      print('result is null');
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    double bill = widget.user.bill;
    double paid = widget.user.paid;
    double surplus = widget.user.getSurplus();

    double verticalPadding = widget.rowHeight * 0.1;
    double horizontalPadding = widget.rowHeight * 0.1;
    double _tabHeight = widget.rowHeight - (2 * verticalPadding);

    bool isBilled = StateInheritedWidget.of(context).isBilled;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: verticalPadding, horizontal: horizontalPadding),
      child: GestureDetector(
        onLongPress: enableCancelButton,
        onTap: () => showUserPage(widget.user),
        child: Stack(
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: _tabHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(_tabHeight / 2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 12, // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.user.userColor[0],
                      maxRadius: _tabHeight / 2 - 10,
                      child: Text(
                        '${widget.user.name.replaceAll(' ', '')[0].toUpperCase()}',
                        style: TextStyle(
                            fontSize: 35,
                            color: widget.user.userColor[1],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.user.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: BDT ${bill.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: isBilled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          children: [
                            surplus > 0
                                ? Icon(Icons.arrow_drop_up,
                                    color: COLOR_GREEN, size: 30)
                                : Icon(Icons.arrow_drop_down,
                                    color: COLOR_RED, size: 30),
                            Text(
                              '${surplus.abs()}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Visibility(
              visible: _showCancelButton,
              child: Positioned(
                top: -5,
                right: 5,
                child: InkWell(
                  onTap: widget.deleteUser,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                        radius: 15.0,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
          ],
          clipBehavior: Clip.none,
        ),
      ),
    );
  }
}

class AddUserCard extends StatefulWidget {
  const AddUserCard({Key? key}) : super(key: key);

  @override
  UserCardState createState() => UserCardState();
}

class UserCardState extends State<AddUserCard> {
  final textController = TextEditingController();

  void onConfirmPressed() {
    Navigator.pop(context, textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 230,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Add New User",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 20.0, height: 1.0, color: Colors.black),
                  ),
                  SizedBox(height: 20),
                  FloatingActionButton.extended(
                      backgroundColor: COLOR_BLACK,
                      onPressed: onConfirmPressed,
                      label: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ))
                ],
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -10.0,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: COLOR_RED,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
        ],
        clipBehavior: Clip.none,
      ),
    );
  }
}
