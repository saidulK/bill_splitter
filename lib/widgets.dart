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

  void onConfirmPressed() {
    Navigator.pop(context, paidAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Add Paid Amount",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.user.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  "BILL :${widget.user.bill}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: priceController,
                  onChanged: (text) {
                    final value = num.tryParse(priceController.text);
                    setState(() {
                      paidAmount = value == null
                          ? 0
                          : double.parse(priceController.text);
                    });
                  },
                  decoration: InputDecoration(
                    errorText: amountInvalid ? 'Invalid Input' : null,
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
      ),
    );
  }
}
