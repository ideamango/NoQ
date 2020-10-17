import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class GenerateScreen extends StatefulWidget {
  final String entityId;
  GenerateScreen({Key key, @required this.entityId}) : super(key: key);
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 5.0;
  static const double _topSectionBottomPadding = 2.0;
  static const double _topSectionHeight = 5.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString;
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();
  Directory tempDir;
  Uri uriLink;
  bool _initCompleted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateQrCode();
  }

  void generateQrCode() {
    //dataString needs to be set, using this the Qr code is generated.

    Utils.createDynamicLinkWithParams(entityId: widget.entityId).then((value) {
      uriLink = value;
      var _dynamicLink = Uri.https(uriLink.authority, uriLink.path).toString();

      _dataString = _dynamicLink.toString();
      _inputErrorText = null;
      _saveImage();
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
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBar(
            titleTxt: "Generate Qr",
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
          bottomNavigationBar: CustomBottomBar(barIndex: 1),
        ),
      );
  }

  Future<void> _saveImage() async {
    try {
      final tempDir = await getTemporaryDirectory();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadImage() async {
    try {
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
          subject: 'SUKOON ~ Book your peace of mind!!',
          text: qrCodeShareMessage,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
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
        // title: 'Add child entities',
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
              titleTxt: "QR Code", backRoute: ManageApartmentsListPage()),
          body: Center(
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * .8,
              height: MediaQuery.of(context).size.width * .9,
              child: Column(
                children: <Widget>[
                  // Expanded(
                  //   child: TextField(
                  //     controller: _textController,
                  //     decoration: InputDecoration(
                  //       hintText: "Enter text for generating QR",
                  //       errorText: _inputErrorText,
                  //       enabledBorder: UnderlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.grey)),
                  //       focusedBorder: UnderlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.orange)),
                  //     ),
                  //   ),
                  // ),

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
        ));
  }
}
