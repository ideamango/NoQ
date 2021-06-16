import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';
import '../constants.dart';
import '../global_state.dart';
import '../pages/help_page.dart';
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
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class UPIPaymentPage extends StatefulWidget {
  final String upiId;
  final String upiQrCodeImgPath;
  final dynamic backRoute;
  final bool isDonation;
  UPIPaymentPage(
      {Key key,
      @required this.upiId,
      @required this.upiQrCodeImgPath,
      @required this.backRoute,
      @required this.isDonation})
      : super(key: key);

  @override
  _UPIPaymentPageState createState() => _UPIPaymentPageState();
}

class _UPIPaymentPageState extends State<UPIPaymentPage> {
  bool initCompleted = false;
  GlobalState _gs;
  String upiId;
  GlobalKey upiKey = new GlobalKey();

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
      _gs = gs;

      if (Platform.isAndroid) {
        _appsFuture = UpiPay.getInstalledUpiApplications();
        _upiAddressController.text = widget.upiId;
      }
      if (Platform.isIOS) {
        //TODO: show the QR code and the UPI ID for IOS users to make the payment
        _upiAddressController.text = widget.upiId;
      }
      setState(() {
        initCompleted = true;
      });
    });

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

  Future<GlobalState> getGlobalState() async {
    return await GlobalState.getGlobalState();
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

      Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6), err,
          "Please enter correct amount and try again.", Colors.red);
      return;
    }
    setState(() {
      _amountError = null;
    });
    print(_upiAddressController.text);

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    final response = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'LESSs',
      receiverUpiAddress: _upiAddressController.text,
      // receiverUpiAddress: _upiAddressController.text,
      transactionRef: transactionRef,
      merchantCode: '7372',
    ).onError((error, stackTrace) => handleUpiPayErrors(error));
    print(response);
    if (response.status == UpiTransactionStatus.failure) {
      Utils.showMyFlushbar(
          context,
          Icons.error,
          Duration(seconds: 6),
          "Could not process UPI payment at this time.",
          "The UPI Id or Amount is incorrect.",
          Colors.red);
    }
  }

  handleUpiPayErrors(dynamic error) {
    print(error.toString());
    String mainMsg;
    String subMsg;
    switch (error.runtimeType) {
      case InvalidAmountException:
        String errorMessage = (error as InvalidAmountException).message;
        subMsg = "Please enter correct amount and try again.";
        if (errorMessage.contains('greater than 1')) {
          mainMsg = 'Amount must be greater than 1';
        } else if (errorMessage.contains('not a valid')) {
          mainMsg = 'The amount entered is not a valid Number.';
        } else if (errorMessage.contains('upper limit')) {
          mainMsg =
              'Amount must be less then 1,00,000 since that is the upper limit per UPI transaction';
        }

        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            mainMsg, subMsg, Colors.red);
        break;
      case InvalidAmountException:
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(seconds: 6),
            "Could not process UPI payment at this time.",
            "Try again with correct UPI Id.",
            Colors.red);
        break;

      default:
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(seconds: 5),
            "Could not process UPI payment at this time.",
            error.toString(),
            Colors.red);
        break;
    }
  }

  _launchURL(String toMailId, String subject, String body) async {
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
          context, Icons.info, Duration(seconds: 3), connectionIssue, "");
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Easy Payments";

    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            drawer: CustomDrawer(
              phone: _gs.getCurrentUser().ph != null
                  ? _gs.getCurrentUser().ph
                  : "",
            ),
            appBar: CustomAppBarWithBackButton(
              backRoute: widget.backRoute,
              titleTxt: title,
            ),
            body: (initCompleted)
                ? SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (widget.isDonation)
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * .11,
                                  margin: EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width * .05,
                                      MediaQuery.of(context).size.width * .04,
                                      MediaQuery.of(context).size.width * .05,
                                      MediaQuery.of(context).size.width * .04),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      //  padding: EdgeInsets.zero,
                                      children: <Widget>[
                                        // Text(
                                        //   'Thats wonderful! ',
                                        //   style: TextStyle(
                                        //       color: Colors.blueGrey[800],
                                        //       fontFamily: 'RalewayRegular',
                                        //       fontSize: 17.0),
                                        // ),
                                        // verticalSpacer,
                                        RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                                style: TextStyle(
                                                    height: 1.3,
                                                    color: Colors.blueGrey[800],
                                                    fontFamily:
                                                        'RalewayRegular',
                                                    fontSize: 12.0),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text:
                                                          'Do MORE with LESSs.\n',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      )),
                                                  TextSpan(
                                                    text: donationMsg1,
                                                  ),
                                                ])),
                                      ]),
                                )
                              : Container(
                                  // margin: EdgeInsets.fromLTRB(
                                  //     5,
                                  //     MediaQuery.of(context).size.width * .1,
                                  //     MediaQuery.of(context).size.width * .05,
                                  //     MediaQuery.of(context).size.width * .04),
                                  // padding: EdgeInsets.zero,
                                  // child: Text(
                                  //   upiHeaderMsg,
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(
                                  //       fontSize: 16, color: Colors.black),
                                  // ),
                                  ),

                          //Phase3 - DO NOT DELETE
                          // Container(
                          //   height: MediaQuery.of(context).size.height * .07,
                          //   margin: EdgeInsets.only(top: 5),
                          //   child: Row(
                          //     children: <Widget>[
                          //       Expanded(
                          //         child: TextFormField(
                          //             controller: _amountController,
                          //             //  readOnly: true,
                          //             enabled: true,
                          //             style: TextStyle(
                          //               fontSize: 14,
                          //               letterSpacing: 1.5,
                          //               color: Colors.blueGrey[600],
                          //             ),
                          //             keyboardType: TextInputType.number,
                          //             autovalidateMode:
                          //                 AutovalidateMode.onUserInteraction,
                          //             decoration: InputDecoration(
                          //               hintText: 'Amount in INR',
                          //               enabledBorder: UnderlineInputBorder(
                          //                   borderSide:
                          //                       BorderSide(color: Colors.grey)),
                          //               focusedBorder: UnderlineInputBorder(
                          //                   borderSide: BorderSide(
                          //                       color: Colors.orange)),
                          //             ),
                          //             validator: (String val) {
                          //               return _validateAmount(val);
                          //             }),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * .08,
                                  //  height: MediaQuery.of(context).size.height * .06,
                                  width: MediaQuery.of(context).size.width * .9,
                                  margin: EdgeInsets.only(
                                      left: 5, top: 0, bottom: 0),
                                  padding: EdgeInsets.zero,
                                  child: AutoSizeText(
                                    directUpiPayMsg,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  )),
                              Divider(
                                indent: 0,
                                thickness: 1,
                                endIndent: 8,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * .45,
                            margin: EdgeInsets.only(top: 20, bottom: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
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
                                      if (Utils.isNotNullOrEmpty(
                                              widget.upiQrCodeImgPath) ||
                                          Utils.isNotNullOrEmpty(
                                              _upiAddressController.text)) {
                                        return Container(
                                          child: Column(
                                            children: [
                                              // Text(
                                              //   donationMessage,
                                              //   style: TextStyle(fontSize: 20),
                                              // ),
                                              Card(
                                                elevation: 8,
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .06,
                                                  // margin: EdgeInsets.only(top: 10),
                                                  padding: EdgeInsets.zero,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Row(
                                                        // crossAxisAlignment:
                                                        //     CrossAxisAlignment.start,
                                                        //mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(10, 0,
                                                                    10, 0),
                                                            child: Text(
                                                              'UPI Id',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                          .blueGrey[
                                                                      400]),
                                                            ),
                                                          ),
                                                          Container(
                                                              child: Text(
                                                            _upiAddressController
                                                                .text,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          )),
                                                        ],
                                                      ),
                                                      IconButton(
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 0),
                                                          alignment:
                                                              Alignment.center,
                                                          highlightColor: Colors
                                                              .orange[300],
                                                          icon: Icon(
                                                            Icons.copy,
                                                          ),
                                                          onPressed: () {
                                                            Clipboard.setData(
                                                                    new ClipboardData(
                                                                        text: _upiAddressController
                                                                            .text))
                                                                .then((_) {
                                                              Utils.showMyFlushbar(
                                                                  context,
                                                                  Icons.copy,
                                                                  Duration(
                                                                      seconds:
                                                                          5),
                                                                  "UPI Id copied to clipboard",
                                                                  "");
                                                            });
                                                          }),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (Utils.isNotNullOrEmpty(
                                                  widget.upiQrCodeImgPath))
                                                Card(
                                                  elevation: 8,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 20),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .3,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "assets/bigpiq_upi.jpg"),
                                                          fit: BoxFit.contain),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Center(
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "No UPI payment apps found on this device.",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  "You can copy the UPI Id and pay via any Payment Channels.",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.blueGrey[600]),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      return Expanded(
                                        child: GridView.count(
                                          crossAxisCount: 2,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                          childAspectRatio: 1.6,
                                          // physics: NeverScrollableScrollPhysics(),
                                          children: snapshot.data
                                              .map((it) => Material(
                                                    key: ObjectKey(
                                                        it.upiApplication),
                                                    color: Colors.grey[200],
                                                    child: InkWell(
                                                      onTap: () => _onTap(it),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Image.memory(
                                                            it.icon,
                                                            width: 64,
                                                            height: 64,
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 4),
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
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Divider(
                                indent: 0,
                                thickness: 1,
                                endIndent: 8,
                                color: Colors.grey[400],
                              ),
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * .1,
                                  child: Text(paymentDisclaimer)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        showCircularProgress(),
                      ],
                    ),
                  ),
          ),
          onWillPop: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomePage()));
            return false;
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
              appBar: CustomAppBar(
                titleTxt: "Donate Money",
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[showCircularProgress()],
                ),
              ),
              bottomNavigationBar: CustomBottomBar(barIndex: 0)),
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }

  showQrDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RepaintBoundary(
                    key: upiKey,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .6,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(widget.upiQrCodeImgPath),
                            fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              ),
              content: Divider(
                color: Colors.blueGrey[400],
                height: 1,
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .3,
                  child: RaisedButton(
                    elevation: 10,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.blueGrey[800],
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[600]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text('Will do later'),
                    onPressed: () {
                      print("Do nothing");
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .4,
                  child: RaisedButton(
                    elevation: 10,
                    color: Colors.white,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: btnColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[600]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text('Share QR'),
                    onPressed: () {
                      //Share QR with others
                      shareQR().then((val) {
                        Navigator.of(context, rootNavigator: true).pop();
                      });
                    },
                  ),
                ),
              ],
            ));
  }

  Future<void> shareQR() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    RenderRepaintBoundary boundary = upiKey.currentContext.findRenderObject();
    var image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    tempDir = await getApplicationDocumentsDirectory();
    // final file =
    //     await new File('${tempDir.path}/qrcodeForShare.png').create();
    final file = new File('${tempDir.path}/bigpiq_gpay.jpg');
    await file.writeAsBytes(pngBytes);
    // final channel = const MethodChannel('channel:me.sukoon.share/share');
    // channel.invokeMethod('shareFile', 'qrcodeForShare.png');
    final RenderBox box = context.findRenderObject();
    Share.shareFiles(['${tempDir.path}/bigpiq_gpay.jpg'],
        subject: upiShareSubject,
        text: upiShareTitle + '\n\n' + upiShareBody,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    if (Platform.isIOS) {
      Share.shareFiles(['${tempDir.path}/bigpiq_gpay.jpg'],
          //subject: msgTitle,
          //text: msgBody,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
}

String _validateAmount(String value) {
  if (value.isEmpty) {
    return 'Amount is required for payment.';
  }
  if (double.tryParse(value) == null) {
    return 'Amount is not a valid number.';
  }
  if (double.tryParse(value) < 1) {
    return 'Amount must be greater than 1.';
  }
  if (double.tryParse(value) > 100000) {
    return 'Amount must be less then 1,00,000 since that is the upper limit per UPI transaction.';
  }

  return null;
}
