import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/widget/appbar.dart';
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
  String _dataString = "Sample QR for NoQ";
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();
  Directory tempDir;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateQrCode();
  }

  void generateQrCode() {
    //dataString needs to be set, using this the Qr code is generated.
    _dataString = widget.entityId;
    _inputErrorText = null;
    _saveImage();
  }

  @override
  Widget build(BuildContext context) {
    return _contentWidget();
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
      tempDir = await getTemporaryDirectory();
      final file =
          await new File('${tempDir.path}/qrcodeForShare.png').create();
      await file.writeAsBytes(pngBytes);
      // final channel = const MethodChannel('channel:me.alfian.share/share');
      // channel.invokeMethod('shareFile', 'qrcodeForShare.png');
    } catch (e) {
      print(e.toString());
    }
  }

  _shareContent() {
    _loadImage();
    String message = 'Hey,' +
        appName +
        ' app is simple and fast way that\n'
            'I use to book appointment for the\n'
            'places I wish to go. It helps to \n'
            'avoid waiting. Check it out yourself.';
    String link = "www.playstore.com";
    //  Share.share(message + link);
    Share.shareFiles(
      ['${tempDir.path}/qrcodeForShare.png'],
      text: 'Check this out',
      subject: "Subject from NoQ",
    );
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
