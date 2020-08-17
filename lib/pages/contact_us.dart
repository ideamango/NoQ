import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
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

  @override
  void initState() {
    super.initState();
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
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
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
                'What\s this about?',
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
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ListView(
                  children: <Widget>[
                    Text('Get in touch'),
                    RichText(
                        text: TextSpan(
                            style: highlightSubTextStyle,
                            children: <TextSpan>[
                          TextSpan(text: contactUsPageHeadline),
                        ])),
                    new ListTile(
                      leading: const Icon(Icons.person),
                      title: nameField,
                    ),
                    new ListTile(
                      leading: const Icon(Icons.phone),
                      title: phField,
                    ),
                    new ListTile(
                      leading: const Icon(Icons.label_important),
                      title: reasonField,
                    ),
                    new ListTile(
                      leading: const Icon(Icons.email),
                      title: Expanded(
                        child: Column(
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
                      color: primaryAccentColor,
                      textColor: Colors.white,
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
                          _launchURL(contactUsMailId, subjectOfMail, _mailBody);
                        }
                      },
                      child: new Text('Send an Email'),
                    ),
                  ],
                ))),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 0,
        ),
      ),
    );
  }
}
