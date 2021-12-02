import 'package:bill_splitter/constants.dart';
import 'package:bill_splitter/itempage.dart';
import 'package:bill_splitter/models.dart';
import 'package:bill_splitter/widgets.dart';
import 'package:bill_splitter/widgets/widgets.dart';
import 'providers/providers.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
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
        backgroundColor: COLOR_BLACK,
        selectedItemColor: COLOR_GREEN,
        unselectedItemColor: Colors.white,
        currentIndex: current_page_index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Items'),
        ],
        onTap: (newIndex) {
          pageController.animateToPage(newIndex,
              duration: Duration(milliseconds: 100), curve: Curves.ease);
        },
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
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();

  void onFloatingButtonPressed(BuildContext context) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent, child: AddUserCard());
        });

    if (result != null && result != "" && result != " ") {
      Provider.of<UserListProvider>(context, listen: false)
          .addToUserList(userData(UniqueKey(), result, 0, 0));
      _animatedListKey.currentState!.insertItem(
          Provider.of<UserListProvider>(context, listen: false)
                  .userList
                  .length -
              1);
    }
  }

  void onCalculatePressed() {
    /*for (final item in StateInheritedWidget.of(context).itemList) {
      print(item.name);
      for (final transaction in item.contributions) {
        print(transaction.user.name);
        print(transaction.amount);
      }
    }*/
  }

  void removeItem(BuildContext context, int index, double rowHeight) {
    userData data =
        Provider.of<UserListProvider>(context, listen: false).userList[index];
    Provider.of<UserListProvider>(context, listen: false)
        .removeAtUserList(context, index);
    Tween<Offset> _offsetTween = Tween(begin: Offset(0, 0), end: Offset(1, 0));

    _animatedListKey.currentState!.removeItem(index, (context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: UserTab(
            key: UniqueKey(),
            user: data,
            deleteUser: () => () {},
            rowHeight: rowHeight),
      );
    });
  }

  Tween<Offset> _offsetTween = Tween(begin: Offset(1, 0), end: Offset(0, 0));

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double bannerHeight = screenHeight * 0.15;
    double reducedListHeight = screenHeight * 0.55;
    double reducedRowHeight = reducedListHeight * 0.7 / 5 / 0.55;
    double listHeight = screenHeight * 0.7;
    double rowHeight = listHeight / 5;

    double topPadding = 0;
    //add in inherited widget
    bool isBilled = Provider.of<BillProvider>(context).isBilled;

    return Column(
      children: [
        Visibility(
          visible: isBilled,
          child: RectangleBanner(
            backgroundColor: COLOR_BLACK,
            height: bannerHeight,
            borderRadius: bannerHeight * 0.15,
            child: Container(
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Total Bill Amount: ',
                    style: TextStyle(color: COLOR_WHITE, fontSize: 20),
                  ),
                  Text(
                    '${Provider.of<BillProvider>(context).totalBill.toStringAsFixed(2)}',
                    style: TextStyle(color: COLOR_GREEN, fontSize: 50),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Container(
            height: isBilled
                ? reducedListHeight - topPadding
                : listHeight - topPadding,
            child: Consumer<UserListProvider>(
              builder:
                  (BuildContext context, UserListProvider userListProvider, _) {
                return AnimatedList(
                    key: _animatedListKey,
                    itemBuilder: (context, index, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        //position: animation.drive(_offsetTween),
                        child: UserTab(
                            key: UniqueKey(),
                            user: userListProvider.userList[index],
                            deleteUser: () => removeItem(context, index,
                                isBilled ? reducedRowHeight : rowHeight),
                            rowHeight: isBilled ? reducedRowHeight : rowHeight),
                      );
                    },
                    initialItemCount: userListProvider.userList.length);
              },
            ),
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
      //
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    double bill = widget.user.bill;
    double paid = widget.user.paid;
    double surplus = widget.user.getSurplus();

    double verticalPadding = widget.rowHeight * 0.1;
    double horizontalPadding = widget.rowHeight * 0.1;
    double _tabHeight = widget.rowHeight - (2 * verticalPadding);

    bool isBilled = Provider.of<BillProvider>(context).isBilled;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: verticalPadding, horizontal: horizontalPadding),
      child: GestureDetector(
        onLongPress: enableCancelButton,
        onTap: () => showUserPage(widget.user),
        child: Stack(
          children: [
            rectangleTab(
                height: _tabHeight,
                borderRadius: _tabHeight / 2,
                shadowColor: widget.user.userColor[0],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatarLetter(
                      backgroundColor: widget.user.userColor[0],
                      radius: _tabHeight / 2 - 10,
                      letter: widget.user.name,
                      fontSize: 35,
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Column(
                          children: [
                            surplus >= 0
                                ? Icon(Icons.arrow_drop_up,
                                    color: COLOR_GREEN, size: 30)
                                : Icon(Icons.arrow_drop_down,
                                    color: COLOR_RED, size: 30),
                            Text(
                              '${surplus.abs().toStringAsFixed(2)}',
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
                child: crossButton(onTap: widget.deleteUser, radius: 15),
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
          rectangleTab(
            height: 230,
            borderRadius: 30,
            h_offset: 20,
            v_offset: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          Positioned(
              top: -10,
              right: -10.0,
              child:
                  crossButton(onTap: () => Navigator.pop(context), radius: 20)),
        ],
        clipBehavior: Clip.none,
      ),
    );
  }
}
