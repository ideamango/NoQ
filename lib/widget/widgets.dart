import 'dart:async';

import 'package:flutter/material.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../global_state.dart';
import '../style.dart';

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

showDialogForPlaceDetails(
    MetaEntity metaEntity, Entity entity, BuildContext context) {
  GlobalState state;
//Fetch Entity
  if (entity == null) {
    // ignore: unnecessary_cast
    GlobalState.getGlobalState().then((value) {
      state = value!;
      state.getEntity(metaEntity.entityId);
    });
  }

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
                        entity.name!,
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
                        "Welcome to ${entity.name}.",
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
                    child: RichText(
                      text: TextSpan(
                        style: subHeadingTextStyle,
                        children: <TextSpan>[
                          TextSpan(text: 'Description - '),
                          // TextSpan(
                          //   text: 'Terms of Use',
                          //   style: new TextStyle(
                          //       color: Colors.cyan[400],
                          //       //decoration: TextDecoration.underline,
                          //       decorationColor: primaryDarkColor),
                          //   recognizer: new TapGestureRecognizer()
                          //     ..onTap = () {
                          //       Navigator.pop(context);
                          //     },
                          // ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpacer,
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(5),
                    child: RichText(
                      text: TextSpan(
                        style: subHeadingTextStyle,
                        children: <TextSpan>[
                          TextSpan(text: 'Timings - '),
                          TextSpan(
                            text: '${entity.startTimeHour}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpacer,
                  // Container(
                  //   height: MediaQuery.of(context).size.height * .2,
                  //   margin: EdgeInsets.zero,
                  //   padding: EdgeInsets.all(5),
                  //   child: Image(image: AssetImage('assets/regain.jpg')),
                  // ),
                  // verticalSpacer,
                  // Container(
                  //     padding: EdgeInsets.symmetric(horizontal: 8),
                  //     child: Text(
                  //       "Welcome to the world of ${str.name}.",
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //           color: Colors.blueGrey[800],
                  //           fontFamily: 'RalewayRegular',
                  //           fontSize: 14.0),
                  //     )),
                  // verticalSpacer,
                  // Container(
                  //   height: MediaQuery.of(context).size.height * .2,
                  //   margin: EdgeInsets.zero,
                  //   padding: EdgeInsets.all(5),
                  //   child: Image(image: AssetImage('assets/1.jpg')),
                  // ),
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
