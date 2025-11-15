import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class CSVHelper {
  static Future<File> exportCSV(List data) async {
    List<List<dynamic>> rows = [
      ["Name", "Roll No", "Subject", "Time"]
    ];

    for (var row in data) {
      rows.add([
        row['name'],
        row['roll'],
        row['subject'],
        row['time']
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/attendance.csv");

    await file.writeAsString(csv);
    return file;
  }
}
