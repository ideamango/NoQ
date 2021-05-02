import 'dart:io';
import 'dart:math';
import 'dart:ui';

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
  UPIPaymentPage(
      {Key key,
      @required this.upiId,
      @required this.upiQrCodeImgPath,
      @required this.backRoute})
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
    String title = "Donate ";

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
                      child: ListView(
                        children: <Widget>[
                          Container(
                            //  height: MediaQuery.of(context).size.height * .1,
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
                                            TextSpan(
                                                text: 'Do MORE with LESSs.\n',
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
                          Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .08,
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        child:
                                            Text(_upiAddressController.text)),
                                    if (Utils.isNotNullOrEmpty(
                                        widget.upiQrCodeImgPath))
                                      IconButton(
                                          visualDensity: VisualDensity.compact,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          alignment: Alignment.center,
                                          highlightColor: Colors.orange[300],
                                          icon: ImageIcon(
                                            AssetImage('assets/qrcode.png'),
                                            size: 25,
                                            color: primaryIcon,
                                          ),
                                          onPressed: () {
                                            showQrDialog();
                                          }),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 0,
                                thickness: 1.5,
                                endIndent: 8,
                                color: Colors.grey[500],
                              )
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * .07,
                            margin: EdgeInsets.only(top: 5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                      controller: _amountController,
                                      //  readOnly: true,
                                      enabled: true,
                                      style: TextStyle(
                                        fontSize: 14,
                                        letterSpacing: 1.5,
                                        color: Colors.blueGrey[600],
                                      ),
                                      keyboardType: TextInputType.number,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        hintText: 'Amount in INR',
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.orange)),
                                      ),
                                      validator: (String val) {
                                        return _validateAmount(val);
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * .53,
                            margin: EdgeInsets.only(top: 20, bottom: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Easy Pay Using UPI Apps',
                                    style: TextStyle(
                                        height: 1.3,
                                        color: Colors.black,
                                        fontFamily: 'RalewayRegular',
                                        fontSize: 14.0),
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
                                      if (Utils.isNotNullOrEmpty(
                                          widget.upiQrCodeImgPath)) {
                                        return Container(
                                          child: Column(
                                            children: [
                                              Text(
                                                'Scan this QR code to make the donation.',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 20),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .35,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/bigpiq_upi.jpg"),
                                                      fit: BoxFit.contain),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          child: Text(
                                              "No UPI payment apps found on this device."),
                                        );
                                      }
                                    } else {
                                      return Expanded(
                                        child: GridView.count(
                                          crossAxisCount: 2,
                                          shrinkWrap: true,
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
    return 'Amount is required.';
  }
  if (double.tryParse(value) == null) {
    return 'Amount is not a valid number.';
  }
  return null;
}
