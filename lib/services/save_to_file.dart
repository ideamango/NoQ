import 'dart:io';
import 'package:path_provider/path_provider.dart';

_read() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_file.txt');
    String text = await file.readAsString();
    print(text);
  } catch (e) {
    print("Couldn't read file");
  }
}

_save(String s) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/my_file.txt');
  final text = 'Hello World!';
  await file.writeAsString(s);
  print('saved');
}
