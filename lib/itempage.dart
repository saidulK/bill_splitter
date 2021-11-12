import 'package:bill_splitter/constants.dart';
import 'package:bill_splitter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/models.dart';

class ItemPage extends StatefulWidget {
  final String title = "ITEM LIST";
  final PageController pageController;
  const ItemPage({Key? key, required this.pageController}) : super(key: key);

  @override
  ItemPageState createState() => ItemPageState();
}

class ItemPageState extends State<ItemPage> with AutomaticKeepAliveClientMixin {
  void onCalculatePressed() {
    StateInheritedWidget.of(context).calculateBill();
    widget.pageController.animateToPage(0,
        duration: Duration(milliseconds: 100), curve: Curves.ease);
  }

  void onFloatingButtonPressed(BuildContext context) async {
    List<userData> nameList = StateInheritedWidget.of(context).userList;

    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return contributionStateWidget(
            child: SingleChildScrollView(
              child: Dialog(
                  backgroundColor: Colors.transparent,
                  child: addItemCard(nameList: nameList)),
            ),
          );
        });

    if (result != null) {
      StateInheritedWidget.of(context).addToItemList(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double rowHeight = MediaQuery.of(context).size.height * 0.15;
    List<userData> nameList = StateInheritedWidget.of(context).userList;
    List<itemData> itemList = StateInheritedWidget.of(context).itemList;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListView.builder(
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      return itemRow(item: itemList[index], height: rowHeight);
                    })),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton.extended(
                  backgroundColor: COLOR_BLACK,
                  onPressed: onCalculatePressed,
                  label: Text('Calculate', style: TextStyle(fontSize: 20)),
                ),
                FloatingActionButton(
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
          SizedBox(height: 70)
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class itemRow extends StatefulWidget {
  final itemData item;
  final double height;
  const itemRow({Key? key, required this.item, required this.height})
      : super(key: key);

  @override
  itemRowState createState() => itemRowState();
}

class itemRowState extends State<itemRow> {
  @override
  Widget build(BuildContext context) {
    double rowWidth = MediaQuery.of(context).size.width * .4;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 12, // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${widget.item.name}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            Text('BDT ${widget.item.price}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            contributorRow(widget.item, widget.height / 2, rowWidth, 10),
            Text('Edit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
          ])
        ],
      ),
    );
  }
}

Widget contributorRow(item, rowHeight, rowWidth, verticalPadding) {
  List<Transaction> contributions = item.contributions;

  return Container(
    height: rowHeight - verticalPadding,
    width: rowWidth,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: contributions.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(right: 10),
          child: CircleAvatar(
            backgroundColor: contributions[index].user.userColor[0],
            radius: rowHeight / 2 - verticalPadding,
            child: Text(
              contributions[index].user.name[0].toUpperCase(),
              style: TextStyle(
                  fontSize: 20,
                  color: contributions[index].user.userColor[1],
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    ),
  );
}

class addItemCard extends StatefulWidget {
  final List<userData> nameList;
  const addItemCard({Key? key, required this.nameList}) : super(key: key);

  @override
  addItemCardState createState() => addItemCardState();
}

class addItemCardState extends State<addItemCard> {
  bool equalDivide = true;

  TextEditingController textController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  //List<userData> nameList = [];
  String itemName = "";
  double itemPrice = 0;
  bool priceInvalid = false;
  bool nameInvalid = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.8;
    double verticalPadding = 10;
    double horizontalPadding = 10.0;

    void onConfirmPressed() {
      List<Transaction> contributions =
          contributionStateInheritedWidget.of(context).currentContributions;

      if (itemName.isNotEmpty && contributions.length != 0) {
        if (equalDivide) {
          List<Transaction> equalContributions =
              List<Transaction>.from(contributions);
          for (final transaction in equalContributions) {
            transaction.amount = itemPrice / equalContributions.length;
          }
          Navigator.pop(
              context,
              itemData(
                  name: itemName,
                  price: itemPrice,
                  contributions: equalContributions));
        } else {
          Navigator.pop(
              context,
              itemData(
                  name: itemName,
                  price: itemPrice,
                  contributions: List<Transaction>.from(contributions)));
        }
      }
      if (contributions.length == 0) {
        print("Add Contributors");
      }
      if (itemName.isEmpty) {
        setState(() => nameInvalid = true);
      }
    }

    return Container(
        padding: EdgeInsets.all(height * 0.05),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: Text(
                "Item Name:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                errorText: nameInvalid ? 'Name Invalid' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (text) {
                setState(() {
                  itemName = textController.text;
                  nameInvalid = false;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: Text(
                "Price:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            TextField(
              controller: priceController,
              onChanged: (text) {
                final value = num.tryParse(priceController.text);

                setState(() {
                  itemPrice =
                      value == null ? 0 : double.parse(priceController.text);
                  priceInvalid = value == null ? true : false;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                errorText: priceInvalid ? 'Invalid Value' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: verticalPadding, horizontal: horizontalPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Contributors:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    CupertinoSwitch(
                        value: equalDivide,
                        onChanged: (value) {
                          setState(() {
                            equalDivide = value;
                          });
                        })
                  ]),
            ),
            Expanded(
                child: ContributorContainer(
              height: height,
              nameList: widget.nameList,
              equalDivide: equalDivide,
            )),
            Padding(
              padding: EdgeInsets.only(top: verticalPadding),
              child: Center(
                child: FloatingActionButton.extended(
                    backgroundColor: COLOR_BLACK,
                    onPressed: () => onConfirmPressed(),
                    label: Text(
                      "Confirm",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    )),
              ),
            )
          ],
        ));
  }
}

class ContributorContainer extends StatefulWidget {
  final double height;
  final List<userData> nameList;
  final bool equalDivide;

  const ContributorContainer(
      {Key? key,
      required this.height,
      required this.nameList,
      required this.equalDivide})
      : super(key: key);

  @override
  ContributorContainerState createState() => ContributorContainerState();
}

class ContributorContainerState extends State<ContributorContainer> {
  //List of Selected contributors
  List<userData> contributorListState = [];

  Color addbuttonColor = Colors.white;

  void showContributorSelectionDialog(
      List<userData> nameList, List<userData> contributorList) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: contributionSelector(
                  nameList: nameList, contributorList: contributorList),
            ),
          );
        });
    if (result != null) {
      setState(() {
        contributorListState.clear();

        for (final user in result) {
          contributorListState.add(user);
          contributionStateInheritedWidget
              .of(context)
              .addToCurrentContributions(Transaction(user, 0));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double rowHeight = widget.height * 0.08;
    double maxHeight = 180;
    double height =
        ((rowHeight + 10) * contributorListState.length + 10) > maxHeight
            ? maxHeight - 20
            : ((rowHeight + 10) * contributorListState.length + 10);

    return Column(
      children: [
        Container(
          height: height,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: contributorListState.length,
              itemBuilder: (context, index) {
                return ContributorTab(
                    key: UniqueKey(),
                    user: contributorListState[index],
                    rowHeight: rowHeight,
                    contribution: 100 / contributorListState.length,
                    equalDivide: widget.equalDivide,
                    index: index);
              }),
        ),
        GestureDetector(
          onTap: () {
            showContributorSelectionDialog(
                widget.nameList, contributorListState);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
                height: rowHeight,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: addbuttonColor,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
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
                      child: Icon(Icons.add, size: 20),
                      radius: rowHeight / 2 - 10,
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: Text(
                            "Add Contributor ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ],
    );
  }
}

class contributionSelector extends StatefulWidget {
  final List<userData> nameList;
  final List<userData> contributorList;

  const contributionSelector(
      {Key? key, required this.nameList, required this.contributorList})
      : super(key: key);

  @override
  contributionSelectorState createState() => contributionSelectorState();
}

class contributionSelectorState extends State<contributionSelector> {
  List<bool> createSelectedList(
      List<userData> nameList, List<userData> contributorList) {
    List<bool> selectedList = [];
    for (var i = 0; i < nameList.length; i++) {
      if (contributorList.contains(nameList[i])) {
        selectedList.add(true);
      } else {
        selectedList.add(false);
      }
    }
    return selectedList;
  }

  @override
  Widget build(BuildContext context) {
    return userSelection(
        userList: widget.nameList,
        selectedList:
            createSelectedList(widget.nameList, widget.contributorList));
  }
}

class ContributorTab extends StatefulWidget {
  final userData user;
  final double rowHeight;
  final double contribution;
  final bool equalDivide;
  final int index;

  const ContributorTab(
      {Key? key,
      required this.user,
      required this.rowHeight,
      required this.contribution,
      required this.equalDivide,
      required this.index})
      : super(key: key);

  @override
  ContributorTabState createState() => ContributorTabState();
}

class ContributorTabState extends State<ContributorTab> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String newContribution =
        '${contributionStateInheritedWidget.of(context).getTransactionforindex(widget.index).amount}';
    final value = num.tryParse(controller.text);
    setState(() {
      newContribution = '${controller.text}';
      contributionStateInheritedWidget
          .of(context)
          .addAmountAtCurrentContributions(
              widget.index, value == null ? 0 : double.parse(controller.text));
    });

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: widget.rowHeight,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: widget.user.userColor[0],
              radius: widget.rowHeight / 2 - 10,
              child: Text(
                widget.user.name[0].toUpperCase(),
                style: TextStyle(
                    fontSize: 15,
                    color: widget.user.userColor[1],
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.user.name,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              width: 50,
              child: widget.equalDivide
                  ? Text(
                      '${widget.contribution.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    )
                  : TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: TextStyle(fontSize: 9.0, color: Colors.black),
                      onChanged: (text) {
                        final value = num.tryParse(controller.text);
                        setState(() {
                          newContribution = '${controller.text}';
                          contributionStateInheritedWidget
                              .of(context)
                              .addAmountAtCurrentContributions(
                                  widget.index,
                                  value == null
                                      ? 0
                                      : double.parse(controller.text));
                        });
                      },
                      onEditingComplete: () {
                        final value = num.tryParse(controller.text);
                        setState(() {
                          newContribution = '${controller.text}';
                          contributionStateInheritedWidget
                              .of(context)
                              .addAmountAtCurrentContributions(
                                  widget.index,
                                  value == null
                                      ? 0
                                      : double.parse(controller.text));
                        });
                      },
                      onSaved: (text) {
                        final value = num.tryParse(controller.text);
                        setState(() {
                          newContribution = '${controller.text}';
                          contributionStateInheritedWidget
                              .of(context)
                              .addAmountAtCurrentContributions(
                                  widget.index,
                                  value == null
                                      ? 0
                                      : double.parse(controller.text));
                        });
                      }),
            )
          ],
        ),
      ),
    );
  }
}
