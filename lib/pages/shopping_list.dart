import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/list_item.dart';
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
    if (Utils.isNullOrEmpty(token.items))
      listOfShoppingItems = List<ListItem>();
    else {
      listOfShoppingItems = token.items;
    }
  }

  void _addNewServiceRow() {
    setState(() {
      ListItem sItem =
          new ListItem(itemName: _item, quantity: "", isDone: false);
      listOfShoppingItems.add(sItem);
      _count = _count + 1;
      token.items.add(sItem);
      //TODO: Smita - Update GS
    });
  }

  void _removeServiceRow(ListItem currItem) {
    setState(() {
      listOfShoppingItems.remove(currItem);
      _count = _count - 1;
      token.items.remove(currItem);
      print(currItem.itemName + ' deleted ' + currItem.quantity);
      //TODO: Smita - Update GS
    });
  }

  Widget _buildServiceItem(ListItem newItem) {
    TextEditingController itemNameController = new TextEditingController();
    itemNameController.text = newItem.itemName;
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
                    width: MediaQuery.of(context).size.width * .2,
                    height: 40,
                    child: TextField(
                      cursorColor: highlightColor,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(12),
                      ],
                      style: TextStyle(fontSize: 14, color: primaryDarkColor),
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.all(12),
                        // labelText: labelTextStr,
                        hintText: 'Quantity',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.length < 8) newItem.quantity = value;
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
                    size: 28,
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
                      concatenate.writeln('Shopping List from Sukoon');
                      concatenate.writeln('-----------------------------');
                      //concatenate.writeln(heading);
                      for (int i; i < listOfShoppingItems.length; i++) {
                        print('i----' +
                            listOfShoppingItems[i].itemName +
                            ' - ' +
                            listOfShoppingItems[i].quantity);
                        if (listOfShoppingItems[i].itemName == null ||
                            listOfShoppingItems[i].itemName.isEmpty) return;
                        concatenate.writeln(listOfShoppingItems[i].itemName +
                            ' - ' +
                            listOfShoppingItems[i].quantity);
                      }
                      print(concatenate);

                      String phoneNo = token.entityWhatsApp;
                      //TODO Smita - remove once whatsapp number gets populated.
                      phoneNo = '+919611009823';
                      if (phoneNo != null)
                        launchWhatsApp(
                            message: concatenate.toString(), phone: phoneNo);
                    } else {
                      print("Nothing to share, add items to list first. ");
                      setState(() {
                        _errMsg = 'Nothing to share, add items to list first.';
                      });
                    }
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
                  Card(
                    elevation: 20,
                    child: Container(
                      height: MediaQuery.of(context).size.width * .13,
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                                  width: MediaQuery.of(context).size.width * .1,
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
