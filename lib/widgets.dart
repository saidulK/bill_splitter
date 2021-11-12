import 'package:bill_splitter/constants.dart';
import 'package:bill_splitter/homepage.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/models.dart';

Widget RectangleTab(
    double height, double hPadding, double vPadding, Widget child) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      height: height,
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
      child: child);
}

class userSelection extends StatefulWidget {
  final List<userData> userList;
  final List<bool> selectedList;
  const userSelection(
      {Key? key, required this.userList, required this.selectedList})
      : super(key: key);

  @override
  userSelectionState createState() => userSelectionState();
}

class userSelectionState extends State<userSelection> {
  List<bool> newSelectedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newSelectedList = widget.selectedList;
  }

  List<userData> getSelectedUserList(
      List<userData> userList, List<bool> selectedList) {
    List<userData> selectedUsers = [];
    for (var i = 0; i < selectedList.length; i++) {
      if (selectedList[i]) {
        selectedUsers.add(userList[i]);
      }
    }
    return selectedUsers;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.8;
    double rowHeight = height * 0.08;
    double verticalPadding = 10;
    double horizontalPadding = 10;
    double containerHeight =
        (rowHeight + 2 * verticalPadding) * newSelectedList.length + 100 >
                height - 2 * verticalPadding
            ? height - 2 * verticalPadding
            : (rowHeight + 2 * verticalPadding) * newSelectedList.length + 100;

    return Container(
        height: containerHeight,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: EdgeInsets.symmetric(
            vertical: 2 * verticalPadding, horizontal: horizontalPadding),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.userList.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      newSelectedList[index] = !newSelectedList[index];
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: verticalPadding,
                        horizontal: horizontalPadding),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                          horizontal: horizontalPadding),
                      height: rowHeight,
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
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  widget.userList[index].userColor[0],
                              radius: rowHeight / 2 - verticalPadding,
                              child: Text(
                                widget.userList[index].name[0].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: widget.userList[index].userColor[1],
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: Container(
                                    child: Center(
                                        child: Text(
                              widget.userList[index].name,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )))),
                            Visibility(
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: newSelectedList[index],
                              child: CircleAvatar(
                                  radius: rowHeight / 2 - verticalPadding,
                                  backgroundColor: COLOR_GREEN,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton.extended(
                backgroundColor: COLOR_BLACK,
                onPressed: () {
                  Navigator.pop(context,
                      getSelectedUserList(widget.userList, newSelectedList));
                },
                label: Text(
                  "Confirm",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ))
          ],
        ));
  }
}

class userPage extends StatefulWidget {
  final userData user;
  const userPage({Key? key, required this.user}) : super(key: key);

  @override
  userPageState createState() => userPageState();
}

class userPageState extends State<userPage> {
  TextEditingController priceController = TextEditingController();
  double paidAmount = 0;
  bool amountInvalid = false;
  List<itemData> ItemList = [];
  List<double> BillList = [];

  void onConfirmPressed() {
    StateInheritedWidget.of(context).addUserPayment(widget.user, paidAmount);
    Navigator.pop(context);
  }

  void setItemList() {
    ItemList.clear();
    BillList.clear();
    for (final item in StateInheritedWidget.of(context).itemList) {
      for (final transaction in item.contributions) {
        if (transaction.user == widget.user) {
          ItemList.add(item);
          BillList.add(transaction.amount);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double bannerHeight = screenHeight * 0.2;
    double tabHeight = screenHeight * 0.08;
    double vPadding = 20;
    double hPadding = 20;
    setItemList();

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: bannerHeight,
              padding: EdgeInsets.symmetric(
                  horizontal: hPadding, vertical: vPadding),
              decoration: BoxDecoration(
                  color: COLOR_BLACK,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.user.userColor[0],
                    radius: bannerHeight / 2 - vPadding,
                    child: Text(
                      widget.user.name[0].toUpperCase(),
                      style: TextStyle(
                          color: widget.user.userColor[1],
                          fontSize: 80,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            color: widget.user.userColor[0],
                            fontSize: 30,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Total Bill Amount',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'BDT ${widget.user.bill.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: screenHeight * 0.75,
              padding: EdgeInsets.symmetric(
                  horizontal: hPadding, vertical: vPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Paid Amount:',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: screenWidth - hPadding,
                    height: tabHeight,
                    decoration: BoxDecoration(
                      color: COLOR_BLACK,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 12, // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Add Payment',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        height: screenHeight * .5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item List:',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            Flexible(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: ItemList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      height: tabHeight,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      margin: EdgeInsets.only(
                                          bottom: 10, right: 10, left: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(tabHeight / 2)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 5,
                                            blurRadius:
                                                12, // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: ListTile(
                                          leading: Text(
                                            ItemList[index].name,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Text(
                                            'BDT ${BillList[index]}',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton.extended(
                        backgroundColor: COLOR_BLACK,
                        onPressed: onConfirmPressed,
                        label: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
