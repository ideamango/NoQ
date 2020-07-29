import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/list_item.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/slotRepository.dart';
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
      listOfShoppingItems.insert(0, sItem);
      _count = _count + 1;
      token.items.add(sItem);
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
          child: new ListTile(
            title: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * .5,
                      child: TextField(
                        style: TextStyle(fontSize: 14, color: primaryDarkColor),
                        controller: itemNameController,
                        decoration: InputDecoration(
                          //contentPadding: EdgeInsets.all(12),
                          // labelText: newItem.itemName,
                          hintText: 'Item name',
                          hintStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
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
                  horizontalSpacer,
                  Container(
                      width: MediaQuery.of(context).size.width * .15,
                      height: 40,
                      child: TextField(
                        maxLines: 1,
                        style: TextStyle(fontSize: 14, color: primaryDarkColor),
                        decoration: InputDecoration(
                          //contentPadding: EdgeInsets.all(12),
                          // labelText: labelTextStr,
                          hintText: 'Quantity',
                          hintStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          newItem.quantity = value;
                        },
                      )),
                  Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
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
                  )
                ],
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    // entity.childCollection
    //    .add(new ChildEntityAppData.cType(value, entity.id));
    //   saveEntityDetails(entity);

    String title = "Shopping List";

    final itemField = new TextFormField(
      // autofocus: true,
      controller: _listItem,
      cursorColor: Colors.blueGrey[500],
      cursorWidth: 1,
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
            actions: <Widget>[],
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
              style: drawerdefaultTextStyle,
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
                  Card(
                    elevation: 20,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
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
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: IconButton(
                                    icon: Icon(Icons.add_circle,
                                        color: highlightColor, size: 40),
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
