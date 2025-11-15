import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  TextEditingController subjectCtrl = TextEditingController();
  String qrData = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate QR Code")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: InputDecoration(
                labelText: "Enter Subject",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Generate QR"),
              onPressed: () {
                String s = subjectCtrl.text.trim();
                if (s.isEmpty) return;

                String time = DateTime.now().toString();
                setState(() {
                  qrData = "$s|$time";
                });
              },
            ),
            SizedBox(height: 20),
            qrData.isEmpty
                ? Text("No QR Generated Yet")
                : QrImageView(data: qrData, size: 250),
          ],
        ),
      ),
    );
  }
}
