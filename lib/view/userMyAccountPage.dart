import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class UserMyAccountPage extends StatefulWidget {
  final Storage storage;
  UserMyAccountPage({Key key, @required this.storage}) : super(key: key);
  @override
  _UserMyAccountPageState createState() => _UserMyAccountPageState();
}

class _UserMyAccountPageState extends State<UserMyAccountPage> {
  TextEditingController textEditingController = TextEditingController();
  String state;
  Future<Directory> _appDocDir;

  String userNickName = 'Smita';

  @override
  void initState() {
    super.initState();
    widget.storage.readData().then((String value) {
      setState(() {
        state = value;
      });
    });
  }

  Future<File> writeData() async {
    setState(() {
      state = textEditingController.text;
      textEditingController.text = '';
    });
    return widget.storage.writeData(state);
  }

  void getAppDirectory() {
    setState(() {
      _appDocDir = getApplicationDocumentsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Text('${state ?? "File is Empty"}'),
        TextField(
          controller: textEditingController,
        ),
        RaisedButton(
          autofocus: false,
          child: Text("Write to file"),
          onPressed: writeData,
        ),
        RaisedButton(
          autofocus: false,
          child: Text("Get Directory"),
          onPressed: getAppDirectory,
        ),
        FutureBuilder<Directory>(
          future: _appDocDir,
          builder: (BuildContext context, AsyncSnapshot<Directory> snapshot) {
            Text text = Text('');
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                text = Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                text = Text('Path: ${snapshot.data.path}');
              } else {
                text = Text('Unavailable');
              }
            }
            return new Container(
              child: text,
            );
          },
        ),
        Text(
          'Testing save n read',
          style: TextStyle(color: Colors.red),
        ),
      ],
    ));
  }
}

class Storage {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      print("Couldn't read file");
      return e.toString();
    }
  }

  Future<File> writeData(String dataToSave) async {
    final file = await localFile;

    return file.writeAsString("$dataToSave");
  }
}
