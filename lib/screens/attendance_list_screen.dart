import 'package:flutter/material.dart';
import '../helpers/storage_helper.dart';
import '../helpers/csv_helper.dart';
import 'package:share_plus/share_plus.dart';

class AttendanceListScreen extends StatefulWidget {
  @override
  _AttendanceListScreenState createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    data = await StorageHelper.getAttendance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Records"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              var file = await CSVHelper.exportCSV(data);
              Share.shareXFiles([XFile(file.path)]);
            },
          )
        ],
      ),
      body: data.isEmpty
          ? Center(child: Text("No attendance saved"))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  title: Text("${item['name']} (${item['roll']})"),
                  subtitle: Text(
                      "Subject: ${item['subject']}\nTime: ${item['time']}"),
                );
              },
            ),
    );
  }
}
