import 'package:bill_splitter/itempage.dart';
import 'package:bill_splitter/models.dart';
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
        appBar: AppBar(title: Text(title)),
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
    setState(() {
      StateInheritedWidget.of(context).removeAtUserList(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<userData> nameList = StateInheritedWidget.of(context).userList;

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return UserTab(
                      key: UniqueKey(),
                      name: nameList[index].name,
                      bill: nameList[index].bill,
                      surplus: nameList[index].getSurplus(),
                      deleteUser: () => removeItem(context, index));
                },
                itemCount: nameList.length),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                onPressed: onCalculatePressed,
                label: Text('Calculate', style: TextStyle(fontSize: 20)),
              ),
              FloatingActionButton(
                onPressed: () => onFloatingButtonPressed(context),
                backgroundColor: Colors.white,
                elevation: 10,
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 70)
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class UserTab extends StatefulWidget {
  final String name;
  final double bill;
  final double surplus;
  final VoidCallback deleteUser;

  const UserTab(
      {Key? key,
      required this.name,
      required this.bill,
      required this.surplus,
      required this.deleteUser})
      : super(key: key);
  @override
  UserTabState createState() => UserTabState();
}

class UserTabState extends State<UserTab> {
  var _showCancelButton = false;
  final double _tabHeight = 90;

  void enableCancelButton() {
    setState(() {
      _showCancelButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onLongPress: enableCancelButton,
        child: Stack(
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: _tabHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 12, // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.pink.shade100,
                      maxRadius: _tabHeight / 2 - 10,
                      child: Text(
                        '${widget.name.replaceAll(' ', '')[0].toUpperCase()}',
                        style: TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'BDT ' + '${widget.bill}',
                            style: TextStyle(fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_drop_up,
                                color: Colors.green, size: 30),
                            Text(
                              '${widget.surplus}',
                              style: TextStyle(fontSize: 20),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Name:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
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
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        child: Text(
                          "Confirm",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: onConfirmPressed,
                  )
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
                    backgroundColor: Colors.red,
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
