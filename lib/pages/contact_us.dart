import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController _mailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phController = new TextEditingController();
  final GlobalKey<FormFieldState> phnKey = new GlobalKey<FormFieldState>();
  TextEditingController _msgController = new TextEditingController();
  String _reasonType;
  List<String> attachments = [];
  String _mailBody;
  String _altPh;
  String _mailFirstline;
  String _mailSecLine;
  bool _validate = false;
  String _errMsg;
  bool initCompleted = false;
  GlobalState _state;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      setState(() {
        initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String validateText(String value) {
    if (value == null || value == "") {
      return 'Please enter your message';
    }
    // _entityDetailsFormKey.currentState.save();
    return null;
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      launch(url).then((value) => Utils.showMyFlushbar(
          context,
          Icons.check,
          Duration(seconds: 5),
          "Your message has been sent.",
          "Our team will contact you as soon as possible."));

      print("Mail sent");
    } else {
      //throw 'Could not launch $url';
      Utils.showMyFlushbar(
          context,
          Icons.check,
          Duration(seconds: 3),
          "Seems to be some problem with internet connection, Please check and try again.",
          "");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBar(
            titleTxt: "Contact Us",
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showCircularProgress(),
              ],
            ),
          ),
          //drawer: CustomDrawer(),
          //bottomNavigationBar: CustomBottomBar(barIndex: 0),
        ),
      );
    } else {
      final nameField = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Name',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        // validator: validateText,
        onSaved: (String value) {
          //entity.address.zipcode = value;
          print("saved address");
        },
      );
      final phField = TextFormField(
        obscureText: false,

        maxLines: 1,
        minLines: 1,
        key: phnKey,
        style: textInputTextStyle,
        keyboardType: TextInputType.phone,
        controller: _phController,
        decoration: InputDecoration(
          labelText: 'Any alternate phone',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        // validator: validateText,
        validator: Utils.validateMobileField,
        onChanged: (value) {
          setState(() {
            _altPh = 'Alternate phone number: ' + _phController.text;
            _mailFirstline = (_phController.text.isNotEmpty) ? _altPh : " ";
          });
        },
        onSaved: (String value) {
          //entity.address.zipcode = value;
          print("saved address");
        },
      );
      final reasonField = new FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              //  icon: const Icon(Icons.person),
              labelText: 'What\s this about?',
            ),
            child: new DropdownButtonHideUnderline(
              child: new DropdownButton(
                hint: new Text(
                  'Select',
                ),
                value: _reasonType,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    _reasonType = newValue;
                    state.didChange(newValue);
                  });
                },
                items: mailReasons.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: new Text(
                      type.toString(),
                      style: textInputTextStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
        onSaved: (String value) {
          _reasonType = value;

          // entity.childCollection
          //    .add(new ChildEntityAppData.cType(value, entity.id));
          //   saveEntityDetails(entity);
        },
      );

      String title = "Contact Us";
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          drawer: CustomDrawer(
            phone: _state.currentUser.ph,
          ),
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: title,
          ),
          body: Center(
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: ListView(
                    children: <Widget>[
                      Text(
                        'Your Feedback is Appreciated',
                        style: highlightMedBoldTextStyle,
                      ),
                      verticalSpacer,
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  color: Colors.blueGrey[800],
                                  fontFamily: 'Montserrat',
                                  fontSize: 13.0),
                              children: <TextSpan>[
                            //TextSpan(text: contactUsPageHeadline),
                            TextSpan(
                                text:
                                    "Did you like what we did?  What else can we do?  How can we improve?"),
                            TextSpan(
                                text: "  We would love to hear from you!!",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextSpan(text: "\nA simple"),
                            TextSpan(
                                text: " kudos, clap",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextSpan(text: " or just a"),
                            TextSpan(
                                text: " Hello",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextSpan(
                                text:
                                    " from you would be a great motivation for our team :)"),
                          ])),
                      new ListTile(
                        leading: Container(
                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: const Icon(Icons.person)),
                        title: nameField,
                      ),
                      new ListTile(
                        leading: Container(
                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: const Icon(Icons.phone)),
                        title: phField,
                      ),
                      new ListTile(
                        leading: Container(
                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: const Icon(Icons.label_important)),
                        title: reasonField,
                      ),
                      new ListTile(
                        leading: Container(
                            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            child: const Icon(Icons.email)),
                        title: Expanded(
                          child: Column(
                            children: <Widget>[
                              TextField(
                                autofocus: false,
                                controller: _msgController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your message here..',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange)),
                                  // errorText:
                                  //     _validate ? 'Please enter your message' : null,
                                ),
                                //validator: validateText,
                                keyboardType: TextInputType.multiline,
                                maxLength: null,
                                maxLines: 3,
                                onChanged: (value) {
                                  if (_msgController.text?.length != 0)
                                    setState(() {
                                      _errMsg = null;
                                    });
                                  setState(() {
                                    _mailSecLine = _msgController.text;
                                    _mailBody =
                                        _mailFirstline + "\n" + _mailSecLine;
                                  });
                                },
                              ),
                              Text(
                                (_errMsg != null) ? _errMsg : "",
                                style: errorTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpacer,
                      new RaisedButton(
                        elevation: 5,
                        color: btnColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.blueGrey[200]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        splashColor: highlightColor,
                        onPressed: () {
                          setState(() {
                            _errMsg = validateText(_msgController.text);
                          });

                          // setState(() {
                          //   _msgController.text.isEmpty
                          //       ? _validate = true
                          //       : _validate = false;
                          // });
                          String subjectOfMail = (_reasonType != null)
                              ? _reasonType
                              : 'Write what\s this about';
                          if (_errMsg == null) {
                            if (_mailBody == null) _mailBody = "";
                            _launchURL(_state.conf.contactEmail, subjectOfMail,
                                _mailBody);
                          }
                        },
                        child: new Text('Send an Email'),
                      ),
                      verticalSpacer,
                      Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        height: 35.0,
                        width: 45.0,
                        child: RaisedButton(
                          textColor: btnColor,
                          elevation: 5,
                          padding: EdgeInsets.all(5),
                          // alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[200]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          color: Colors.white,
                          splashColor: highlightColor,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Say 'Hi' to us on "),
                                ImageIcon(
                                  AssetImage('assets/whatsapp.png'),
                                  size: 30,
                                  color: Colors.greenAccent[700],
                                ),
                              ],
                            ),
                          ),

                          onPressed: () {
                            if (_state.conf.whatsappPhone != null &&
                                _state.conf.whatsappPhone != "") {
                              try {
                                launchWhatsApp(
                                    message: whatsappContactUsMsg,
                                    phone: _state.conf.whatsappPhone);
                              } catch (error) {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.error,
                                    Duration(seconds: 5),
                                    "Could not connect to the Whatsapp number ${_state.conf.whatsappPhone} !!",
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

                            // callPhone('+919611009823');
                            //callPhone(str.);
                          },
                        ),
                      ),
                    ],
                  ))),
          // bottomNavigationBar: CustomBottomBar(
          //   barIndex: 0,
          // ),
        ),
      );
    }
  }
}
