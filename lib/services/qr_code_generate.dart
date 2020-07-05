import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
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
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 5.0;
  static const double _topSectionBottomPadding = 2.0;
  static const double _topSectionHeight = 5.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();

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
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);
      final channel = const MethodChannel('channel:me.alfian.share/share');
      channel.invokeMethod('shareFile', 'image.png');
    } catch (e) {
      print(e.toString());
    }
  }

  _shareContent() {
    String message = 'Hey,' +
        appName +
        ' app is simple and fast way that\n'
            'I use to book appointment for the\n'
            'places I wish to go. It helps to \n'
            'avoid waiting. Check it out yourself.';
    String link = "www.playstore.com";
    Share.share(message + link);
  }

  _contentWidget() {
    //final bodyHeight = 100.0;
    //  MediaQuery.of(context).size.height -
    //     MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: 150,
      child: Card(
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Enter text for generating QR",
                  errorText: _inputErrorText,
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    color: Colors.transparent,
                    child: Text("Generate QR"),
                    onPressed: () {
                      print('In submit');
                      setState(() {
                        _dataString = _textController.text;
                        _inputErrorText = null;
                      });
                      _saveImage();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    color: Colors.transparent,
                    child: Text("Share QR"),
                    onPressed: () {
                      _shareContent();
                      print('called share contet');
                    },
                  ),
                ),
              ],
            ),
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
          ],
        ),
      ),
    );
  }
}
