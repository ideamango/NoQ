import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
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
  String _msg;
  final GlobalKey<FormState> _shoppingListFormKey = new GlobalKey<FormState>();
  List<String> listOfNotes;
  TextEditingController _listItem = new TextEditingController();
  String _item;
  bool _initCompleted = false;

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
    //  if (Utils.isNullOrEmpty(token.list))
    listOfNotes = List<String>();
    //else {
    //  listOfNotes = token.list;
    // }
  }

  void _addNewServiceRow() {
    setState(() {
      listOfNotes.add(_item);
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(String newItem) {
    return new Text(newItem);
  }

  @override
  Widget build(BuildContext context) {
    // entity.childCollection
    //    .add(new ChildEntityAppData.cType(value, entity.id));
    //   saveEntityDetails(entity);

    String title = "List  ";

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
          contentPadding: EdgeInsets.fromLTRB(20, 7, 5, 7),
          isDense: true,
          suffixIconConstraints: BoxConstraints(
            maxWidth: 25,
            maxHeight: 22,
          ),
          //contentPadding: EdgeInsets.all(0),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0.5),
          ),
          // suffixIcon: new IconButton(
          //   constraints: BoxConstraints.tight(Size(15, 15)),
          //   alignment: Alignment.centerLeft,
          //   padding: EdgeInsets.all(0),
          //   icon: new Icon(
          //     Icons.add,
          //     size: 17,
          //     color: highlightColor,
          //   ),
          //   onPressed: () {
          //     TODO: correct search end
          //     print("adding to list");
          //     listOfNotes.add(_item);
          //     _listItem.text = "";
          //   },
          // ),
          hintText: "Add items",
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
                          (_msg != null)
                              ? Text(
                                  _msg,
                                  style: errorTextStyle,
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: itemField,
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.add_circle,
                                        color: highlightColor, size: 40),
                                    onPressed: () {
                                      if (_item != null) {
                                        setState(() {
                                          _msg = null;
                                        });
                                        if (_shoppingListFormKey.currentState
                                            .validate()) {
                                          _shoppingListFormKey.currentState
                                              .save();
                                          _addNewServiceRow();
                                          _listItem.text = "";
                                        }
                                      } else {
                                        setState(() {
                                          _msg = "Nothing to add in notes";
                                        });
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
                              children:
                                  listOfNotes.map(_buildServiceItem).toList()),
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
