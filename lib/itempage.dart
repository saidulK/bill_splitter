import 'package:bill_splitter/widgets/edit_button.dart';
import 'package:flutter/material.dart';
import 'package:bill_splitter/constants.dart';
import 'package:bill_splitter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:bill_splitter/models.dart';
import 'providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:bill_splitter/widgets/widgets.dart';

class ItemPage extends StatefulWidget {
  final String title = "ITEM LIST";
  final PageController pageController;
  const ItemPage({Key? key, required this.pageController}) : super(key: key);

  @override
  ItemPageState createState() => ItemPageState();
}

class ItemPageState extends State<ItemPage> with AutomaticKeepAliveClientMixin {
  void onFloatingButtonPressed(BuildContext context) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Dialog(
                backgroundColor: Colors.transparent,
                child: addItemCard(edit: false, index: 0)),
          );
        });

    if (result != null) {
      Provider.of<ItemListProvider>(context, listen: false)
          .addToItemList(result, "add ");
      Provider.of<BillProvider>(context, listen: false).calculateBill(context);
    }
  }

  void deleteItem(int index) {
    Provider.of<ItemListProvider>(context, listen: false)
        .removeAtItemList(index, "delete");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double rowHeight = MediaQuery.of(context).size.height * 0.15;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Consumer<ItemListProvider>(
                  builder: (context, itemListProvider, _) {
                    return ListView.builder(
                        itemCount: itemListProvider.itemList.length,
                        itemBuilder: (context, index) {
                          return itemRow(
                              key: UniqueKey(),
                              item: itemListProvider.itemList[index],
                              height: rowHeight,
                              index: index,
                              callback: () => deleteItem(index));
                        });
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Center(
              child: FloatingActionButton(
                onPressed: () => onFloatingButtonPressed(context),
                backgroundColor: COLOR_BLACK,
                elevation: 10,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
          SizedBox(height: 10)
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
  final int index;
  final VoidCallback callback;
  const itemRow(
      {Key? key,
      required this.item,
      required this.height,
      required this.index,
      required this.callback})
      : super(key: key);

  @override
  itemRowState createState() => itemRowState();
}

class itemRowState extends State<itemRow> {
  var _showCancelButton = false;

  void onEditPressed(BuildContext context, int index) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Dialog(
                backgroundColor: Colors.transparent,
                child: addItemCard(edit: true, index: index)),
          );
        });

    if (result != null) {
      Provider.of<ItemListProvider>(context, listen: false)
          .updateItemAt(index, result, "editing item");
      Provider.of<BillProvider>(context, listen: false).calculateBill(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double rowWidth = MediaQuery.of(context).size.width * .4;

    return GestureDetector(
      onLongPress: () => setState(() => _showCancelButton = true),
      child: Stack(
        children: [
          rectangleTab(
            height: widget.height,
            borderRadius: widget.height / 5,
            v_offset: 15,
            h_offset: 20,
            h_margin: 10,
            v_margin: 10,
            shadowColor:
                widget.item.isInvalid() ? COLOR_RED : COLOR_SHADOW_GREY,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.item.name}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      contributorRow(
                          widget.item, widget.height / 2, rowWidth, 10)
                    ]),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('BDT',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
                        Text('${widget.item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w500)),
                      ]),
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _showCancelButton
                ? crossButton(onTap: () => widget.callback(), radius: 15)
                : editButton(
                    onTap: () => onEditPressed(context, widget.index),
                    radius: 15),
          ),
        ],
        clipBehavior: Clip.none,
      ),
    );
  }
}

Widget contributorRow(item, rowHeight, rowWidth, verticalPadding) {
  return Container(
    height: rowHeight - verticalPadding,
    width: rowWidth,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: item.contributions.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatarLetter(
              backgroundColor: item.contributions[index].user.userColor[0],
              radius: rowHeight / 2 - verticalPadding,
              letter: item.contributions[index].user.name,
              fontSize: 20,
              textColor: item.contributions[index].user.userColor[1],
            ));
      },
    ),
  );
}

class addItemCard extends StatefulWidget {
  //final List<userData> nameList;
  final bool edit;
  final int index;
  const addItemCard({Key? key, required this.edit, required this.index})
      : super(key: key);

  @override
  addItemCardState createState() => addItemCardState();
}

class addItemCardState extends State<addItemCard> {
  bool equalDivide = true;
  String itemName = "";
  double itemPrice = 0;
  List<Transaction> itemContributions = [];
  bool priceInvalid = false;
  bool nameInvalid = false;
  TextEditingController textController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => setInitialValues(context));
  }

  void setInitialValues(BuildContext context) {
    setState(() {
      if (widget.edit) {
        itemData selectedItem =
            Provider.of<ItemListProvider>(context, listen: false)
                .itemList[widget.index];
        itemName = selectedItem.name;
        itemPrice = selectedItem.price;
        textController.text = itemName;
        priceController.text = '${itemPrice}';
        itemContributions = selectedItem.contributions;
        for (final contribution in selectedItem.contributions) {
          if (contribution.amount != selectedItem.contributions[0].amount) {
            equalDivide = false;
          }
        }
      }
    });
  }

  void onConfirmPressed() {
    itemContributions =
        Provider.of<ItemContribuitionsProvider>(context, listen: false)
            .itemContributions;

    if (itemName.isNotEmpty && itemContributions.length != 0) {
      if (equalDivide) {
        List<Transaction> equalContributions =
            List<Transaction>.from(itemContributions);
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
        double total = 0;
        for (final t in itemContributions) {
          total += t.amount;
        }
        if (total == itemPrice) {
          Navigator.pop(
              context,
              itemData(
                  name: itemName,
                  price: itemPrice,
                  contributions: List<Transaction>.from(itemContributions)));
        } else {
          print("Show error in contributions");
        }
      }
    }
    if (itemContributions == 0) {
      print("Add Contributors");
    }
    if (itemName.isEmpty) {
      setState(() => nameInvalid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.8;
    double verticalPadding = 10;
    double horizontalPadding = 10.0;

    return rectangleTab(
        height: height,
        borderRadius: 30,
        h_offset: height * 0.05,
        v_offset: height * 0.05,
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
              edit: widget.edit,
              index: widget.index,
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
  final bool equalDivide;
  final bool edit;
  final int index;

  const ContributorContainer(
      {Key? key,
      required this.height,
      required this.equalDivide,
      required this.edit,
      required this.index})
      : super(key: key);

  @override
  ContributorContainerState createState() => ContributorContainerState();
}

class ContributorContainerState extends State<ContributorContainer> {
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => setInitialContributors(context));
  }

  setInitialContributors(BuildContext context) {
    if (widget.edit) {
      Provider.of<ItemContribuitionsProvider>(context, listen: false)
              .itemContributions =
          Provider.of<ItemListProvider>(context, listen: false)
              .itemList[widget.index]
              .contributions;
    } else {
      Provider.of<ItemContribuitionsProvider>(context, listen: false)
          .clearContributions();
    }
  }

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
      Provider.of<ItemContribuitionsProvider>(context, listen: false)
          .clearContributions();
      for (final user in result) {
        Provider.of<ItemContribuitionsProvider>(context, listen: false)
            .addToCurrentContributions(Transaction(user, 0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> itemContributions =
        Provider.of<ItemContribuitionsProvider>(context, listen: false)
            .itemContributions;
    double rowHeight = widget.height * 0.08;
    double maxHeight = 180;

    List<userData> userList =
        Provider.of<UserListProvider>(context, listen: false).userList;

    return Column(
      children: [
        Consumer<ItemContribuitionsProvider>(builder: (BuildContext context,
            ItemContribuitionsProvider itemContributionsProvider, _) {
          return Container(
              height: ((rowHeight + 10) *
                              itemContributionsProvider
                                  .itemContributions.length +
                          10) >
                      maxHeight
                  ? maxHeight - 20
                  : ((rowHeight + 10) *
                          itemContributionsProvider.itemContributions.length +
                      10),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: itemContributionsProvider.itemContributions.length,
                  itemBuilder: (context, index) {
                    return ContributorTab(
                        key: UniqueKey(),
                        user: itemContributionsProvider
                            .itemContributions[index].user,
                        rowHeight: rowHeight,
                        contribution: widget.equalDivide
                            ? 100 /
                                itemContributionsProvider
                                    .itemContributions.length
                            : itemContributions[index].amount,
                        equalDivide: widget.equalDivide,
                        index: index);
                  }));
        }),
        GestureDetector(
          onTap: () {
            showContributorSelectionDialog(
                userList,
                Provider.of<ItemContribuitionsProvider>(context, listen: false)
                    .contributors);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
                height: rowHeight,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: COLOR_WHITE,
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
        '${Provider.of<ItemContribuitionsProvider>(context, listen: false).getTransactionforindex(widget.index).amount}';
    controller.text = newContribution;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: widget.rowHeight,
        decoration: BoxDecoration(
          color: COLOR_WHITE,
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
                        Provider.of<ItemContribuitionsProvider>(context,
                                listen: false)
                            .addAmountAtCurrentContributions(
                                widget.index,
                                value == null
                                    ? 0
                                    : double.parse(controller.text));
                      }),
            )
          ],
        ),
      ),
    );
  }
}
