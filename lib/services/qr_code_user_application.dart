import 'package:flutter/material.dart';
import '../constants.dart';
import '../pages/manage_child_entity_list_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/manage_entity_details_page.dart';
import '../pages/user_account_page.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class GenerateQrUserApplication extends StatefulWidget {
  final String applicationId;
  final String entityName;
  final String backRoute;
  GenerateQrUserApplication(
      {Key key,
      @required this.applicationId,
      @required this.entityName,
      @required this.backRoute})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => GenerateQrUserApplicationState();
}

class GenerateQrUserApplicationState extends State<GenerateQrUserApplication> {
  dynamic route;

  GlobalKey globalKey = new GlobalKey();
  String _dataString;
  Directory tempDir;
  Uri uriLink;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    generateQrCode();
    if (widget.backRoute == "UserAppsList") {
      route = UserAccountPage();
    }
    if (widget.backRoute == "EntityList") {
      route = ManageEntityListPage();
    }
  }

  void generateQrCode() {
    //dataString needs to be set, using this the Qr code is generated.
    Utils.createQrScreenForUserApplications(
            widget.applicationId, widget.entityName)
        .then((value) {
      uriLink = value;
      // var _dynamicLink = Uri.https(uriLink.authority, uriLink.path).toString();
      var _dynamicLink = uriLink;
      _dataString = _dynamicLink.toString();
      setState(() {
        _initCompleted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted)
      return _contentWidget();
    else
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: CustomAppBar(
              titleTxt: "Generate QR",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Padding(padding: EdgeInsets.only(top: 20.0)),
                  showCircularProgress()
                ],
              ),
            ),
            //drawer: CustomDrawer(),
            // bottomNavigationBar: CustomBottomBar(barIndex: 1),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
  }

  Future<void> _loadImage() async {
    try {
      //Dynamic Link Text
      //'LESSs ~ Book your peace of mind!!'
      // String msgTitle = qrCodeShareHeading + " - " + widget.entityName;
      String msgTitle = applicationShareMessage;
      String msgBody = qrCodeShareMessage;

      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      tempDir = await getApplicationDocumentsDirectory();
      // final file =
      //     await new File('${tempDir.path}/qrcodeForShare.png').create();
      final file = new File('${tempDir.path}/qrcodeForShare.png');
      await file.writeAsBytes(pngBytes);
      // final channel = const MethodChannel('channel:me.sukoon.share/share');
      // channel.invokeMethod('shareFile', 'qrcodeForShare.png');
      final RenderBox box = context.findRenderObject();
      Share.shareFiles(['${tempDir.path}/qrcodeForShare.png'],
          subject: msgTitle,
          text: msgTitle + '\n\n' + msgBody,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      if (Platform.isIOS) {
        Share.shareFiles(['${tempDir.path}/qrcodeForShare.png'],
            //subject: msgTitle,
            //text: msgBody,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _shareContent() {
    // String message = 'Hey,' +
    //     appName +
    //     ' app is simple and fast way that\n'
    //         'I use to book appointment for the\n'
    //         'places I wish to go. It helps to \n'
    //         'avoid waiting. Check it out yourself.';
    _loadImage().then((value) {
      //String link = "www.playstore.com";
      //  Share.share(message + link);
      // Share.shareFiles(
      //   ['${tempDir.path}/qrcodeForShare.png'],
      //   text: message,
      //   subject: "Subject from NoQ",
      print("Share done");
      // );
    });
  }

  _contentWidget() {
    //final bodyHeight = 100.0;
    //  MediaQuery.of(context).size.height -
    //     MediaQuery.of(context).viewInsets.bottom;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Add child entities',
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          appBar:
              CustomAppBarWithBackButton(titleTxt: "QR Code", backRoute: route),
          body: Center(
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * .8,
              height: MediaQuery.of(context).size.width * .9,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: Container(
                          color: Colors.white,
                          child: QrImage(
                            data: _dataString,
                            size: MediaQuery.of(context).size.width * .9,
                            errorStateBuilder: (cxt, err) {
                              return Container(
                                child: Center(
                                  child: Text(
                                    "Uh oh! Something went wrong!! May be the text is too long. Try again.",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.orange)),
                          color: Colors.transparent,
                          child: Text("Share QR Code"),
                          onPressed: () {
                            _shareContent();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
