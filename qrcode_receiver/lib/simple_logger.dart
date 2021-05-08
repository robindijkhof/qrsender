import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/simplelog.txt');
}

Future<List<String>> _readLogs() async {
  try {
    final file = await _localFile;

    // Read the file.
    List<String> lines = await file.readAsLines();

    return lines;
  } catch (e) {
    // If encountering an error, return empty.
    return [];
  }
}


class SimpleLogger {
  static final SimpleLogger _singleton = SimpleLogger._internal();

  final ReplaySubject<List<DateTime>> _$logs = new ReplaySubject(maxSize: 1);

  factory SimpleLogger() {
    return _singleton;
  }

  SimpleLogger._internal(){
    _readLogs()
        .asStream()
        .map((x) => x.map((y) => DateTime.parse(y)))
        .map((x) => x.toList().reversed.toList())
        .first
        .then((value) => _$logs.add(value.toList()));
  }

  Stream<List<DateTime>> getLogs(){
    return _$logs.asBroadcastStream();
  }

  Future<void> logNow() async {
    final file = await _localFile;

    _$logs.first.then((value) => _$logs.add(List.from(value)..insert(0, DateTime.now())));

    return file.writeAsString('${DateTime.now().toIso8601String()}\n', mode: FileMode.append);
  }

}
