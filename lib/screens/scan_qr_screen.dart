import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../providers/qr_provider.dart';

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  String? _scannedQRData;
  bool _scannedOnce = false;
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Consumer3<AttendanceProvider, StudentProvider, QRProvider>(
        builder: (context, attendanceProvider, studentProvider, qrProvider, child) {
          final students = studentProvider.students;

          return Column(
            children: [
              // Camera Preview
              if (!_scannedOnce)
                Expanded(
                  child: MobileScanner(
                    onDetect: (BarcodeCapture capture) {
                      if (_scannedOnce) return;
                      
                      final barcode = capture.barcodes.first;
                      final value = barcode.rawValue ?? "";

                      if (value.isNotEmpty && value.contains("|")) {
                        setState(() {
                          _scannedQRData = value;
                          _scannedOnce = true;
                        });
                      }
                    },
                  ),
                )
              else
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 64),
                          SizedBox(height: 16),
                          Text(
                            "QR Code Scanned!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Form after scanning
              if (_scannedQRData != null && _scannedQRData!.contains("|")) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Scanned QR Data",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _scannedQRData!,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (students.isEmpty)
                        Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(height: 8),
                                Text(
                                  "No students found",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Please add students first",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          value: _selectedStudentId,
                          decoration: InputDecoration(
                            labelText: "Select Student *",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: students.map((student) {
                            return DropdownMenuItem(
                              value: student.id,
                              child: Text("${student.name} (${student.rollNumber})"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStudentId = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _selectedStudentId == null || attendanceProvider.isLoading
                              ? null
                              : () async {
                                  final success = await attendanceProvider.markAttendance(
                                    _selectedStudentId!,
                                    _scannedQRData!,
                                  );

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Attendance marked successfully!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          attendanceProvider.error ?? "Failed to mark attendance",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          icon: attendanceProvider.isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.check),
                          label: Text(attendanceProvider.isLoading
                              ? "Saving..."
                              : "Mark Attendance"),
                        ),
                        SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _scannedQRData = null;
                              _scannedOnce = false;
                              _selectedStudentId = null;
                            });
                          },
                          icon: Icon(Icons.refresh),
                          label: Text("Scan Again"),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
