import 'dart:convert';
import 'dart:io';
import 'package:noq/global_state.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get localFile async {
  final path = await localPath;
  return File('$path/noq_db.txt');
}

String generateJson(GlobalState state) {
  //TODO: SMIta - null exception thrown , check
  //String json = jsonEncode(state);
  Map<String, dynamic> json = state.toJson();
  String jsonStr = jsonEncode(json);
  return jsonStr;
}

void writeData(GlobalState state) async {
  // json = jsonEncode(dummyUser);
  final file = await localFile;
  String fileData = generateJson(state);
  //print('Writing in file $file , data: $fileData');
  await file.writeAsString("$fileData");
}

Future<GlobalState> readData() async {
  try {
    final file = await localFile;
    //TODO: SAmita Exception here
    String body = await file.readAsString();
    print('Reading data: $body');
    Map<String, dynamic> json = jsonDecode(body);
    GlobalState state = GlobalState.fromJson(json);
    return state;
  } catch (e) {
    print("Couldn't read the file");
    return null;
  }
}
