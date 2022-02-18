import 'package:flutter/material.dart';
import '../constants.dart';
import '../global_state.dart';
import '../services/circular_progress.dart';
import '../services/url_services.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/header.dart';
import '../widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateFields extends StatefulWidget {
  final bool showAppBar;
  CreateFields({Key? key, required this.showAppBar}) : super(key: key);

  @override
  _CreateFieldsState createState() => _CreateFieldsState();
}

class _CreateFieldsState extends State<CreateFields> {
  TextEditingController _mailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phController = new TextEditingController();
  final GlobalKey<FormFieldState> phnKey = new GlobalKey<FormFieldState>();
  TextEditingController _msgController = new TextEditingController();
  String? _reasonType;
  List<String> attachments = [];
  String? _mailBody;
  String? _altPh;
  String? _mailFirstline;
  late String _mailSecLine;
  bool _validate = false;
  String? _errMsg;
  bool initCompleted = false;
  GlobalState? _state;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? validateText(String value) {
    if (value == null || value == "") {
      return 'Please enter your message';
    }
    // _entityDetailsFormKey.currentState.save();
    return null;
  }

  _launchURL(String? toMailId, String? subject, String? body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      launch(url).then((value) => Utils.showMyFlushbar(
          context,
          Icons.check,
          Duration(seconds: 5),
          "Your message has been sent.",
          "Our team will contact you as soon as possible.",
          successGreenSnackBar));

      print("Mail sent");
    } else {
      //throw 'Could not launch $url';
      Utils.showMyFlushbar(
          context,
          Icons.info,
          Duration(seconds: 3),
          "Seems to be some problem with internet connection, Please check and try again.",
          "");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initCompleted) {
      return WillPopScope(
        child: Scaffold(
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
        onWillPop: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserHomePage()));
          return false;
        },
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
        onSaved: (String? value) {
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
        onSaved: (String? value) {
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
                onChanged: (dynamic newValue) {
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
        onSaved: (String? value) {
          _reasonType = value;

          // entity.childCollection
          //    .add(new ChildEntityAppData.cType(value, entity.id));
          //   saveEntityDetails(entity);
        },
      );

      String title = "Contact Us";
      return WillPopScope(
        child: Scaffold(
          drawer: CustomDrawer(
            phone: _state!.getCurrentUser()!.ph,
          ),
          appBar: widget.showAppBar
              ? CustomAppBarWithBackButton(
                  backRoute: UserHomePage(),
                  titleTxt: title,
                )
              : null,
          body: Center(
              child: Container(
                  height: MediaQuery.of(context).size.height * .85,
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * .05,
                      MediaQuery.of(context).size.width * .04,
                      MediaQuery.of(context).size.width * .05,
                      MediaQuery.of(context).size.width * .04),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Text(
                        'Your Feedback is Appreciated',
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 17.0),
                      ),
                      verticalSpacer,
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  height: 1.3,
                                  color: Colors.blueGrey[800],
                                  fontFamily: 'RalewayRegular',
                                  fontSize: 13.0),
                              children: <TextSpan>[
                            //TextSpan(text: contactUsPageHeadline),
                            TextSpan(text: contactUsLine1),
                            TextSpan(
                                text: contactUsLine2,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextSpan(text: contactUsLine3),
                            TextSpan(
                                text: contactUsLine4,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextSpan(text: contactUsLine5),
                            TextSpan(
                                text: contactUsLine6,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextSpan(text: contactUsLine7),
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
                        title: Column(
                          children: <Widget>[
                            TextField(
                              autofocus: false,
                              controller: _msgController,
                              decoration: InputDecoration(
                                labelText: 'Enter your message here..',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
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
                                      _mailFirstline! + "\n" + _mailSecLine;
                                });
                              },
                            ),
                            Text(
                              (_errMsg != null) ? _errMsg! : "",
                              style: errorTextStyle,
                            ),
                          ],
                        ),
                      ),
                      verticalSpacer,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(0),
                            height: 35.0,
                            width: MediaQuery.of(context).size.width * .41,
                            child: RaisedButton(
                              textColor: btnColor,
                              elevation: 5,
                              padding: EdgeInsets.all(5),
                              // alignment: Alignment.center,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.blueGrey[200]!),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              color: btnColor,
                              splashColor: highlightColor,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      "WhatsApp Us ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    ImageIcon(
                                      AssetImage('assets/whatsapp.png'),
                                      size: 28,
                                      color: Colors.lightGreenAccent[700],
                                    ),
                                  ],
                                ),
                              ),

                              onPressed: () {
                                if (_state!.getConfigurations()!.whatsappPhone !=
                                        null &&
                                    _state!.getConfigurations()!.whatsappPhone !=
                                        "") {
                                  try {
                                    launchWhatsApp(
                                        message: whatsappContactUsMsg,
                                        phone: _state!
                                            .getConfigurations()!
                                            .whatsappPhone);
                                  } catch (error) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.error,
                                        Duration(seconds: 5),
                                        "Could not connect to the WhatsApp number ${_state!.getConfigurations()!.whatsappPhone} !!",
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

                                // callPhone('+919611009823');
                                //callPhone(str.);
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(0),
                            height: 35.0,
                            width: MediaQuery.of(context).size.width * .41,
                            child: RaisedButton(
                              elevation: 5,
                              color: btnColor,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.blueGrey[200]!),
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
                                String? subjectOfMail = (_reasonType != null)
                                    ? _reasonType
                                    : 'Write what\s this about';
                                if (_errMsg == null) {
                                  if (_mailBody == null) _mailBody = "";
                                  _launchURL(
                                      _state!.getConfigurations()!.contactEmail,
                                      subjectOfMail,
                                      _mailBody);
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Text('Email Us'),
                                  Icon(Icons.mail)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))),
          // bottomNavigationBar: CustomBottomBar(
          //   barIndex: 0,
          // ),
        ),
        onWillPop: () async {
          return true;
        },
      );
    }
  }
}
