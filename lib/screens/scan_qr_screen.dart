import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../helpers/storage_helper.dart';

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  String qrText = "";
  bool scannedOnce = false;

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController rollCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Column(
        children: [
          /// CAMERA PREVIEW FOR WINDOWS & ANDROID
          Expanded(
            child: MobileScanner(
              // ✔ Latest API: only 1 parameter
              onDetect: (BarcodeCapture capture) {
                if (scannedOnce) return;
                scannedOnce = true;

                final barcode = capture.barcodes.first;
                final value = barcode.rawValue ?? "";

                setState(() {
                  qrText = value;
                });
              },
            ),
          ),

          /// SHOW FORM AFTER SCANNING
          if (qrText.contains("|")) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Scanned: $qrText",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 15),

                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Enter Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 10),

                  TextField(
                    controller: rollCtrl,
                    decoration: InputDecoration(
                      labelText: "Enter Roll No",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    child: Text("Save Attendance"),
                    onPressed: () {
                      final parts = qrText.split("|");

                      StorageHelper.saveAttendance({
                        "name": nameCtrl.text.trim(),
                        "roll": rollCtrl.text.trim(),
                        "subject": parts[0],
                        "time": parts[1],
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Attendance Saved!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
