import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/db_model/list_item.dart';
import '../db/db_model/message.dart';
import '../db/db_model/order.dart';
import '../db/db_model/user_token.dart';
import '../repository/slotRepository.dart';
import '../services/url_services.dart';
import '../style.dart';
import 'package:flutter/foundation.dart';
import '../utils.dart';

class ShoppingList extends StatefulWidget {
  final UserToken token;
  final bool isAdmin;
  ShoppingList({Key key, @required this.token, @required this.isAdmin})
      : super(key: key);
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final String title = "Notes";

  UserToken token;
  final GlobalKey<FormState> _shoppingListFormKey = new GlobalKey<FormState>();
  List<ListItem> listOfShoppingItems;
  TextEditingController _listItem = new TextEditingController();

  String _item;
  bool _initCompleted = false;
  bool _checked = false;
  String _errMsg;
  bool isPublic = false;

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
          entityId: token.parent.entityId,
          isPublic: false,
          userId: token.parent.userId);
      token.order = ord;
      listOfShoppingItems = token.order.items;
    } else {
      isPublic = token.order.isPublic;
      listOfShoppingItems = token.order.items;
    }
  }

  void _addNewServiceRow() {
    setState(() {
      ListItem sItem = new ListItem(itemName: _item, isDone: false);
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
    });
  }

  Widget _buildServiceItem(ListItem newItem) {
    TextEditingController itemNameController = new TextEditingController();
    //TextEditingController itemQtyController = new TextEditingController();
    itemNameController.text = newItem.itemName;
    //itemQtyController.text = newItem.quantity;
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
                      if (widget.isAdmin) {
                        Utils.showMyFlushbar(
                            context,
                            Icons.info,
                            Duration(seconds: 4),
                            "Admin cannot modify the list by User",
                            "");
                      } else {
                        setState(() {
                          newItem.isDone = value;
                        });
                      }
                    },
                    activeColor: primaryIcon,
                    checkColor: primaryAccentColor,
                  ),
                ),
                Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * .5,
                    child: TextField(
                      enabled: (widget.isAdmin) ? false : true,
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
                  height: 45,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: MediaQuery.of(context).size.width * .1,
                  child: IconButton(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.delete,
                        color: (widget.isAdmin)
                            ? disabledColor
                            : Colors.blueGrey[400],
                        size: 20),
                    onPressed: () {
                      if (!widget.isAdmin) {
                        if (_shoppingListFormKey.currentState.validate()) {
                          _shoppingListFormKey.currentState.save();
                          _removeServiceRow(newItem);
                          _listItem.text = "";
                        }
                      } else {
                        Utils.showMyFlushbar(
                            context,
                            Icons.info,
                            Duration(seconds: 4),
                            "Admin cannot modify the list by User",
                            "");
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

    String title = "Notes";

    final itemField = new TextFormField(
      autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(18),
      ],
      controller: _listItem,
      cursorColor: highlightColor,
      enabled: (widget.isAdmin) ? false : true,
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
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      //theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
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
                        String heading = "Items List from Sukoon";
                        concatenate.writeln(heading);
                        // concatenate.writeln("x~x~x~x~ LESSs ~x~x~x~x");
                        concatenate.writeln("Token: " + token.getDisplayName());
                        // concatenate.writeln("x~x~x~x~x~x~x~x~x~x~x~x~x");
                        // concatenate.writeln("Token: " + token.getDisplayName());
                        //  concatenate.writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~');
                        // concatenate.writeln('------------------------------');

                        int count = 1;
                        for (int i = 0; i < listOfShoppingItems.length; i++) {
                          if (listOfShoppingItems[i].itemName == null ||
                              listOfShoppingItems[i].itemName.isEmpty) return;

                          concatenate.writeln(count.toString() +
                              ") " +
                              listOfShoppingItems[i].itemName);

                          count++;
                        }

                        //   concatenate.writeln("**************************");
                        //    concatenate.writeln("x~x~x~x~x~x~x~x~x~x~x~x~x");

                        String phoneNo = token.parent.entityWhatsApp;
                        if (phoneNo != null) {
                          try {
                            launchWhatsApp(
                                message: concatenate.toString(),
                                phone: phoneNo);
                          } catch (error) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.error,
                                Duration(seconds: 5),
                                "Could not connect to the WhatsApp number $phoneNo !!",
                                "Try again later");
                          }
                        } else {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info,
                              Duration(seconds: 5),
                              "WhatsApp contact information not found!!",
                              "");
                        }
                      } else {
                        print("Nothing to share, add items to list first. ");
                        setState(() {
                          _errMsg =
                              'Nothing to share, add items to list first.';
                        });
                      }
                    },
                  ),
                ),
                //ToDo Smita - PHASE2
                // Container(
                //   padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                //   child: IconButton(
                //     icon: Icon(Icons.payment, size: 28),
                //     onPressed: () {
                //       launchGPay();
                //     },
                //   ),
                // ),
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
                    updateToken(token.parent);
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
                    if (!widget.isAdmin)
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            width: MediaQuery.of(context).size.width * .75,
                            child: AutoSizeText(
                              "Turn ON to share this list with the place Admin",
                              maxLines: 2,
                              minFontSize: 10,
                              maxFontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .08,
                            width: MediaQuery.of(context).size.width * .2,
                            child: Transform.scale(
                              scale: .7,
                              alignment: Alignment.centerRight,
                              child: Switch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: isPublic,
                                onChanged: (value) {
                                  setState(() {
                                    isPublic = value;
                                    token.order.isPublic = value;
                                    print(isPublic);
                                    //}
                                  });
                                },
                                // activeTrackColor: Colors.green,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
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
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      child: itemField,
                                    ),
                                    Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .1,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              .1,
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(Icons.add_circle,
                                            color: highlightColor, size: 38),
                                        onPressed: () {
                                          if (widget.isAdmin) {
                                            Utils.showMyFlushbar(
                                                context,
                                                Icons.info,
                                                Duration(seconds: 4),
                                                "Admin cannot modify the list by User",
                                                "");
                                          } else {
                                            if (_shoppingListFormKey
                                                .currentState
                                                .validate()) {
                                              _shoppingListFormKey.currentState
                                                  .save();
                                              _addNewServiceRow();
                                              _listItem.text = "";
                                            }
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
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
