import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/list_item.dart';
import 'package:noq/db/db_model/message.dart';
import 'package:noq/db/db_model/order.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';
import 'package:uuid/uuid.dart';

class ShoppingList extends StatefulWidget {
  final UserToken token;
  ShoppingList({Key key, @required this.token}) : super(key: key);
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final String title = "Shopping list";

  UserToken token;
  final GlobalKey<FormState> _shoppingListFormKey = new GlobalKey<FormState>();
  List<ListItem> listOfShoppingItems;
  TextEditingController _listItem = new TextEditingController();

  String _item;
  bool _initCompleted = false;
  bool _checked = false;
  String _errMsg;

//Add service Row

  int _count = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    token = widget.token;
    if (token.order == null) {
      Order ord = new Order(
          billNo: "",
          items: List<ListItem>(),
          comments: List<Message>(),
          status: null,
          billAmount: null,
          deliveryMode: null,
          deliveryAddress: null,
          orderCreatedDateTime: null,
          deliveryDateTime: null,
          entityId: token.entityId,
          userId: token.userId);
      token.order = ord;
      listOfShoppingItems = token.order.items;
    } else {
      listOfShoppingItems = token.order.items;
    }
  }

  void _addNewServiceRow() {
    setState(() {
      ListItem sItem =
          new ListItem(itemName: _item, quantity: "", isDone: false);
      listOfShoppingItems.add(sItem);
      _count = _count + 1;
      //token.order.items.add(sItem);
      //TODO: Smita - Update GS
    });
  }

  void _removeServiceRow(ListItem currItem) {
    setState(() {
      listOfShoppingItems.remove(currItem);
      _count = _count - 1;
      //token.order.items.remove(currItem);
      print(currItem.itemName + ' deleted- qty ' + currItem.quantity);
      //TODO: Smita - Update GS
    });
  }

  Widget _buildServiceItem(ListItem newItem) {
    TextEditingController itemNameController = new TextEditingController();
    TextEditingController itemQtyController = new TextEditingController();
    itemNameController.text = newItem.itemName;
    itemQtyController.text = newItem.quantity;
    return Container(
        height: 40,
        child: Card(
          semanticContainer: true,
          elevation: 15,
          margin: EdgeInsets.all(2),
          child: Container(
            height: 45,
            //padding: EdgeInsets.fromLTRB(4, 8, 4, 14),
            margin: EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 40,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: MediaQuery.of(context).size.width * .06,
                  child: Checkbox(
                    value: newItem.isDone,
                    onChanged: (value) {
                      setState(() {
                        newItem.isDone = value;
                      });
                    },
                    activeColor: primaryIcon,
                    checkColor: primaryAccentColor,
                  ),
                ),
                Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * .5,
                    child: TextField(
                      cursorColor: highlightColor,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(18),
                      ],
                      style: TextStyle(fontSize: 14, color: primaryDarkColor),
                      controller: itemNameController,
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.all(12),
                        // labelText: newItem.itemName,
                        hintText: 'Item name',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        newItem.itemName = value;
                      },
                    )

                    // Text(
                    //   newItem.itemName,ggg

                    // ),
                    ),
                // horizontalSpacer,
                Container(
                    width: MediaQuery.of(context).size.width * .25,
                    height: 20,
                    child: TextFormField(
                      cursorColor: highlightColor,
                      maxLines: 1,
                      maxLength: 8,
                      // inputFormatters: [
                      //   LengthLimitingTextInputFormatter(15),
                      // ],
                      style: TextStyle(fontSize: 10, color: primaryDarkColor),
                      //  controller: itemQtyController,
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.all(12),
                        // labelText: labelTextStr,
                        hintText: 'Quantity',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        newItem.quantity = value;
                      },
                    )),

                Container(
                  height: 45,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: MediaQuery.of(context).size.width * .1,
                  child: IconButton(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.delete,
                        color: Colors.blueGrey[300], size: 20),
                    onPressed: () {
                      if (_shoppingListFormKey.currentState.validate()) {
                        _shoppingListFormKey.currentState.save();
                        _removeServiceRow(newItem);
                        _listItem.text = "";
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // entity.childCollection
    //    .add(new ChildEntityAppData.cType(value, entity.id));
    //   saveEntityDetails(entity);

    String title = "Shopping List";

    final itemField = new TextFormField(
      autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(18),
      ],
      controller: _listItem,
      cursorColor: highlightColor,
      //cursorWidth: 1,
      style: new TextStyle(
        // backgroundColor: Colors.white,
        color: Colors.blueGrey[500],
      ),
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5, 7, 5, 7),
          isDense: true,
          suffixIconConstraints: BoxConstraints(
            maxWidth: 22,
            maxHeight: 22,
          ),
          // contentPadding: EdgeInsets.all(0),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Add items to the list",
          hintStyle: new TextStyle(fontSize: 12, color: Colors.blueGrey[500])),
      onChanged: (value) {
        setState(() {
          _item = value;
          _errMsg = "";
        });
      },
      onSaved: (newValue) {
        _item = newValue;
      },
    );

    return MaterialApp(
      title: 'Notes',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: IconButton(
                  icon: ImageIcon(
                    AssetImage('assets/whatsapp.png'),
                    size: 26,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (listOfShoppingItems.length != 0) {
                      print("This list will be shared");

                      var concatenate = StringBuffer();
                      // Widget heading = Text(
                      //   'Shopping List from Sukoon',
                      //   style: TextStyle(decoration: TextDecoration.underline),
                      // );

                      concatenate.writeln("x~x~x~x~ SUKOON ~x~x~x~x");
                      concatenate.writeln("Token ~ " + token.getDisplayName());
                      concatenate.writeln("x~x~x~x~x~x~x~x~x~x~x~x~x");
                      //concatenate.writeln("Token: " + token.getDisplayName());
                      //concatenate.writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~');
                      // concatenate.writeln('------------------------------');
                      //concatenate.writeln(heading);
                      int count = 1;
                      for (int i = 0; i < listOfShoppingItems.length; i++) {
                        if (listOfShoppingItems[i].itemName == null ||
                            listOfShoppingItems[i].itemName.isEmpty) return;

                        concatenate.writeln(count.toString() +
                            ") " +
                            listOfShoppingItems[i].itemName +
                            ((listOfShoppingItems[i].quantity != null &&
                                    listOfShoppingItems[i].quantity != "")
                                ? (' - ' + listOfShoppingItems[i].quantity)
                                : ""));

                        count++;
                      }

                      //concatenate.writeln("**************************");
                      concatenate.writeln("x~x~x~x~x~x~x~x~x~x~x~x~x");

                      String phoneNo = token.entityWhatsApp;

                      if (phoneNo != null) {
                        try {
                          launchWhatsApp(
                              message: concatenate.toString(), phone: phoneNo);
                        } catch (error) {
                          Utils.showMyFlushbar(
                              context,
                              Icons.error,
                              Duration(seconds: 5),
                              "Could not connect to the Whatsapp number $phoneNo !!",
                              "Try again later");
                        }
                      } else {
                        Utils.showMyFlushbar(
                            context,
                            Icons.info,
                            Duration(seconds: 5),
                            "Whatsapp contact information not found!!",
                            "");
                      }
                    } else {
                      print("Nothing to share, add items to list first. ");
                      setState(() {
                        _errMsg = 'Nothing to share, add items to list first.';
                      });
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: IconButton(
                  icon: Icon(Icons.payment, size: 28),
                  onPressed: () {
                    launchGPay();
                  },
                ),
              ),
            ],
            flexibleSpace: Container(
              decoration: gradientBackground,
            ),
            leading: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                highlightColor: highlightColor,
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  print("going back");
                  updateToken(token);
                  Navigator.of(context).pop();
                }),
            title: Text(
              title,
              style: whiteBoldTextStyle1,
              overflow: TextOverflow.ellipsis,
            )),
        body: Center(
          child: new Form(
            key: _shoppingListFormKey,
            autovalidate: true,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  new Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      //scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: new Column(
                              children: listOfShoppingItems
                                  .map(_buildServiceItem)
                                  .toList()),
                        );
                      },
                      itemCount: 1,
                    ),
                  ),
                  Text(
                    (_errMsg != null) ? _errMsg : "",
                    style: errorTextStyle,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 8),
                    child: Card(
                      elevation: 20,
                      child: Container(
                        height: MediaQuery.of(context).size.width * .13,
                        decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //subEntityType,

                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child: itemField,
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    width:
                                        MediaQuery.of(context).size.width * .1,
                                    height:
                                        MediaQuery.of(context).size.width * .1,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Icons.add_circle,
                                          color: highlightColor, size: 38),
                                      onPressed: () {
                                        if (_shoppingListFormKey.currentState
                                            .validate()) {
                                          _shoppingListFormKey.currentState
                                              .save();
                                          _addNewServiceRow();
                                          _listItem.text = "";
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // bottomNavigationBar: buildBottomItems()
          ),
        ),
      ),
    );
  }
}
