import 'dart:convert';
import 'dart:io';
import '../global_state.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:json_annotation/json_annotation.dart';

Future<String> get localPath async {
  final directory = await getTemporaryDirectory();
  return directory.path;
}

Future<File> get localFile async {
  final path = await localPath;
  return File('$path/noq_db.txt');
}

void writeData(Map<String, dynamic> gsJson) async {
  // json = jsonEncode(dummyUser);
  final file = await localFile;
  String fileData = jsonEncode(gsJson);
  //print('Writing in file $file , data: $fileData');
  await file.writeAsString("$fileData");
}

Future<Map<String, dynamic>> readData() async {
  try {
    final file = await localFile;
    //TODO: SAmita Exception here
    String body = await file.readAsString();
    print('Reading data: $body');
    Map<String, dynamic> json = jsonDecode(body);
    return json;
  } catch (e) {
    print("Couldn't read the file");
    return null;
  }
}
