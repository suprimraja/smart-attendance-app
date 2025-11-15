import 'package:hive/hive.dart';

class StorageHelper {
  static Future saveAttendance(Map<String, dynamic> item) async {
    var box = Hive.box('attendance');
    box.add(item);
  }

  static Future<List> getAttendance() async {
    var box = Hive.box('attendance');
    return box.values.toList();
  }
}
