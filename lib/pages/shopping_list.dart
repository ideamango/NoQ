import 'package:flutter/material.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<String> showTokenAlert(
      BuildContext context, String tokenNo, String storeName, String time) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            //  title:
            backgroundColor: Colors.grey[200],
            titleTextStyle: inputTextStyle,
            elevation: 10.0,
            content: Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "fg",
                      style: TextStyle(
                          color: primaryDarkColor,
                          fontFamily: 'Monsterrat',
                          fontSize: 18.0),
                    ),
                    Divider(color: Colors.blueGrey[400], height: 1),
                    verticalSpacer,
                    Text("yhu", style: highlightSubTextStyle),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * .72,
                      height: MediaQuery.of(context).size.width * .12,
                      decoration: new BoxDecoration(
                        color: primaryIcon,
                      ),
                      child: Text("hj", style: homeMsgStyle3),
                    ),
                    RichText(
                        text: TextSpan(
                            style: highlightSubTextStyle,
                            children: <TextSpan>[
                          TextSpan(text: "hjk"),
                          TextSpan(
                              text: " uyi",
                              style: TextStyle(
                                  color: highlightColor, fontSize: 12)),
                        ])),
                    verticalSpacer,
                    Divider(color: Colors.blueGrey[400], height: 1),
                  ],
                )),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: RaisedButton(
                  elevation: 15.0,
                  color: highlightColor,
                  textColor: Colors.white,
                  child: Text('Ok'),
                  onPressed: () {
                    //Navigator.of(context).pushReplacement(StoreLiPage());
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        }).then((val) {
      print(val);
      return val;
    });
  }

  Widget build(BuildContext context) {
    //if (_upcomingBkgStatus == 'Success') {
    String title = "Shopping List";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: CustomAppBarWithBackButton(
          titleTxt: title,
          backRoute: SearchStoresPage(forPage: "Search"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
//          defaultColumnWidth:
//              FixedColumnWidth(MediaQuery.of(context).size.width / 3),
            border: TableBorder.all(
                color: Colors.black12, width: 1, style: BorderStyle.none),
            columnWidths: {
              0: FractionColumnWidth(.3),
              1: FractionColumnWidth(.4),
              2: FractionColumnWidth(.3)
            },
            children: [
              TableRow(children: [
                TableCell(
                    child: Center(
                        child: Column(
                  children: <Widget>[
                    Text(
                      'Notes',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextFormField(
                      obscureText: false,
                      style: textInputTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Type Text Here',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: 3,
                      minLines: 3,
                      onSaved: (String value) {},
                    ),
                  ],
                ))),
                TableCell(
                  child: Center(
                      child:
                          Text('Shopping List', style: highlightBoldTextStyle)),
                ),
                TableCell(
                    child: Center(
                        child: Column(
                  children: <Widget>[
                    Text(
                      'Notes',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextFormField(
                      obscureText: false,
                      style: textInputTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Type Text Here',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: 3,
                      minLines: 3,
                      onSaved: (String value) {},
                    ),
                  ],
                ))),
              ]),
              TableRow(children: [
                TableCell(
                  child: Center(child: Text('Bread')),
                  verticalAlignment: TableCellVerticalAlignment.bottom,
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(child: Text('Value')),
                ),
                TableCell(
                  child: Center(child: Text('Value')),
                  verticalAlignment: TableCellVerticalAlignment.top,
                ),
              ]),
              TableRow(children: [
                TableCell(child: Center(child: Text('Value'))),
                TableCell(
                  child: Center(child: Text('Value')),
                ),
                TableCell(child: Center(child: Text('Value'))),
              ]),
              TableRow(children: [
                TableCell(child: Center(child: Text('Value'))),
                TableCell(
                  child: Center(child: Text('Value')),
                ),
                TableCell(child: Center(child: Text('Value'))),
              ])
            ],
          ),
        ),
        drawer: CustomDrawer(),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 0,
        ),
      ),
    );
  }
}
