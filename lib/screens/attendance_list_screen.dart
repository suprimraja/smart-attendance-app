import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../helpers/csv_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class AttendanceListScreen extends StatefulWidget {
  @override
  _AttendanceListScreenState createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final _searchController = TextEditingController();
  String? _filterSubjectId;
  String? _filterStudentId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Records"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportCSV(context),
            tooltip: "Export to CSV",
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          var attendanceList = provider.attendanceList;

          // Apply filters
          if (_filterSubjectId != null) {
            attendanceList = attendanceList
                .where((a) => a.subjectId == _filterSubjectId)
                .toList();
          }

          if (_filterStudentId != null) {
            attendanceList = attendanceList
                .where((a) => a.studentId == _filterStudentId)
                .toList();
          }

          // Apply search
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            attendanceList = attendanceList.where((a) {
              return a.studentName.toLowerCase().contains(query) ||
                  a.rollNumber.toLowerCase().contains(query) ||
                  a.subjectName.toLowerCase().contains(query);
            }).toList();
          }

          if (attendanceList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No attendance records",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search and Filter
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search attendance...",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilterChip(
                            label: Text(_filterSubjectId == null
                                ? "All Subjects"
                                : "Filtered"),
                            selected: _filterSubjectId != null,
                            onSelected: (selected) {
                              if (!selected) {
                                setState(() {
                                  _filterSubjectId = null;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: FilterChip(
                            label: Text(_filterStudentId == null
                                ? "All Students"
                                : "Filtered"),
                            selected: _filterStudentId != null,
                            onSelected: (selected) {
                              if (!selected) {
                                setState(() {
                                  _filterStudentId = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Attendance List
              Expanded(
                child: ListView.builder(
                  itemCount: attendanceList.length,
                  itemBuilder: (context, index) {
                    final attendance = attendanceList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text(attendance.studentName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Roll: ${attendance.rollNumber}"),
                            Text("Subject: ${attendance.subjectName}"),
                            Text(
                              DateFormat('MMM dd, yyyy - HH:mm')
                                  .format(attendance.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(
                            context,
                            provider,
                            attendance.id,
                            attendance.studentName,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportCSV(BuildContext context) async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final attendanceList = provider.attendanceList;

    if (attendanceList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No attendance data to export")),
      );
      return;
    }

    try {
      // Convert to old format for CSV helper
      final data = attendanceList.map((a) => {
        'name': a.studentName,
        'roll': a.rollNumber,
        'subject': a.subjectName,
        'time': a.timestamp.toIso8601String(),
      }).toList();

      final file = await CSVHelper.exportCSV(data);
      await Share.shareXFiles([XFile(file.path)], text: 'Attendance Export');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to export: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AttendanceProvider provider,
    String id,
    String studentName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Attendance"),
        content: Text("Are you sure you want to delete attendance for $studentName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteAttendance(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Attendance deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}
