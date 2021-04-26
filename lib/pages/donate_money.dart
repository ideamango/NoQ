import 'dart:math';

import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/help_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:upi_pay/upi_pay.dart';
import 'package:url_launcher/url_launcher.dart';

class DonatePage extends StatefulWidget {
  final String phone;
  DonatePage({Key key, @required this.phone}) : super(key: key);

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  bool initCompleted = false;
  GlobalState _gs;
  String upiId;

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    getGlobalState().then((gs) {
      setState(() {
        initCompleted = true;
      });
    });
    //TODO fetch UPI id from global state/configuration
    // _gs.getConfigurations()
    //
    upiId = '6281581624@okbizaxis';
    // _amountController.text =
    //     (Random.secure().nextDouble() * 10).toStringAsFixed(2);
    _appsFuture = UpiPay.getInstalledUpiApplications();
    _upiAddressController.text = upiId;

    super.initState();
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  String _amountError;

  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isUpiEditable = false;
  Future<List<ApplicationMeta>> _appsFuture;

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  // void _generateAmount() {
  //   setState(() {
  //     _amountController.text =
  //         (Random.secure().nextDouble() * 10).toStringAsFixed(2);
  //   });
  // }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateAmount(_amountController.text);
    if (err != null) {
      setState(() {
        _amountError = err;
      });
      return;
    }
    setState(() {
      _amountError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    final a = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'LESSs',
      receiverUpiAddress: upiId,
      // receiverUpiAddress: _upiAddressController.text,
      transactionRef: transactionRef,
      merchantCode: '7372',
    );

    print(a);
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomePage()));
            return false;
          },
        ),
      );
    } else {
      String title = "Donate ";
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
              drawer: CustomDrawer(
                phone: _gs.getCurrentUser().ph,
              ),
              appBar: CustomAppBarWithBackButton(
                backRoute: HelpPage(
                  phone: widget.phone,
                ),
                titleTxt: title,
              ),
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  children: <Widget>[
                    Center(
                      child: Container(
                        //  height: MediaQuery.of(context).size.height * .85,
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * .05,
                            MediaQuery.of(context).size.width * .04,
                            MediaQuery.of(context).size.width * .05,
                            MediaQuery.of(context).size.width * .04),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //  padding: EdgeInsets.zero,
                            children: <Widget>[
                              Text(
                                'Thats wonderful! ',
                                style: TextStyle(
                                    color: Colors.blueGrey[800],
                                    fontFamily: 'RalewayRegular',
                                    fontSize: 17.0),
                              ),
                              verticalSpacer,
                              RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      style: TextStyle(
                                          height: 1.3,
                                          color: Colors.blueGrey[800],
                                          fontFamily: 'RalewayRegular',
                                          fontSize: 12.0),
                                      children: <TextSpan>[
                                        //TextSpan(text: contactUsPageHeadline),
                                        // TextSpan(
                                        //     text:
                                        //         "When you donate it motivates and help keep our Spirits high.\n "),

                                        TextSpan(
                                            text:
                                                'We can do MORE with LESSs.\n',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            )),
                                        TextSpan(
                                          text:
                                              'Everything counts, So donate any amount as per your wish.',
                                        ),
                                      ])),
                            ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _upiAddressController,
                              enabled: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange)),
                                hintText: 'address@upi',
                                labelText: 'Receiving UPI Address',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                                controller: _amountController,
                                //  readOnly: true,
                                enabled: true,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount in INR',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange)),
                                ),
                                onChanged: (value) {
                                  _validateAmount(value);
                                }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Pay Using',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          FutureBuilder<List<ApplicationMeta>>(
                            future: _appsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return Container();
                              }
                              print(snapshot.data.length);
                              if (snapshot.data.length == 0) {
                                //  print("Have some data..huh!!");
                                return Container(
                                  child: Text(
                                    'No payment apps found!',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                );
                              } else {
                                return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1.6,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: snapshot.data
                                      .map((it) => Material(
                                            key: ObjectKey(it.upiApplication),
                                            color: Colors.grey[200],
                                            child: InkWell(
                                              onTap: () => _onTap(it),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.memory(
                                                    it.icon,
                                                    width: 64,
                                                    height: 64,
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      it.upiApplication
                                                          .getAppName(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }
}

String _validateAmount(String value) {
  if (value.isEmpty) {
    return 'Amount is required.';
  }
  if (double.tryParse(value) == null) {
    return 'Amount is not a valid number.';
  }
  return null;
}
