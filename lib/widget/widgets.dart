import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/style.dart';

Divider myDivider = new Divider(
  color: Colors.blueGrey[500],
  height: 2,
  indent: 30,
  endIndent: 30,
);
Divider myLightDivider = new Divider(
  color: Colors.white,
  height: 2,
  indent: 30,
  endIndent: 30,
);

SizedBox verticalSpacer = new SizedBox(height: 10);
SizedBox horizontalSpacer = new SizedBox(width: 10);

showDialogForPlaceDetails(Entity str, BuildContext context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(0),
            actionsPadding: EdgeInsets.all(5),
            //buttonPadding: EdgeInsets.all(0),
            title: Container(
              height: MediaQuery.of(context).size.height * .065,
              color: Colors.cyan[200],
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * .1,
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.cancel,
                          color: headerBarColor,
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        }),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .6,
                      alignment: Alignment.center,
                      child: Text(
                        str.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 19.0),
                      )),
                ],
              ),
            ),

            content: Container(
              color: Colors.cyan[50],
              width: double.maxFinite,
              child: ListView(
                children: <Widget>[
                  Divider(
                    height: 1,
                    color: primaryDarkColor,
                  ),
                  Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Welcome to the world of ${str.name}.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 14.0),
                      )),
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(5),
                    child: Image(image: AssetImage('assets/6.jpg')),
                  ),
                  verticalSpacer,
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Welcome to the world of ${str.name}.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 14.0),
                      )),
                  verticalSpacer,
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(5),
                    child: Image(image: AssetImage('assets/regain.jpg')),
                  ),
                  verticalSpacer,
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Welcome to the world of ${str.name}.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 14.0),
                      )),
                  verticalSpacer,
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(5),
                    child: Image(image: AssetImage('assets/1.jpg')),
                  ),
                ],
              ),
            ),

            //content: Text('This is my content'),
            actions: <Widget>[
              SizedBox(
                height: 24,
                child: RaisedButton(
                  elevation: 0,
                  color: Colors.transparent,
                  splashColor: highlightColor.withOpacity(.8),
                  textColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.orange)),
                  child: Text('Book now and avail offers!!'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
              ),
              // SizedBox(
              //   height: 24,
              //   child: RaisedButton(
              //     elevation: 20,
              //     autofocus: true,
              //     focusColor: highlightColor,
              //     splashColor: highlightColor,
              //     color: Colors.white,
              //     textColor: Colors.orange,
              //     shape: RoundedRectangleBorder(
              //         side: BorderSide(color: Colors.orange)),
              //     child: Text('No'),
              //     onPressed: () {
              //       print("Do nothing");
              //       Navigator.of(context, rootNavigator: true).pop();
              //       // Navigator.of(context, rootNavigator: true).pop('dialog');
              //     },
              //   ),
              // ),
            ],
          ));
}
