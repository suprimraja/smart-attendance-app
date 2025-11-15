import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/qr_provider.dart';
import '../providers/subject_provider.dart';

class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate QR Code")),
      body: Consumer2<QRProvider, SubjectProvider>(
        builder: (context, qrProvider, subjectProvider, child) {
          final activeSession = qrProvider.activeSession;
          final subjects = subjectProvider.subjects;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (activeSession != null) ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Active QR Session",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text("Subject: ${activeSession.subjectName}"),
                          Text("Started: ${_formatDateTime(activeSession.startTime)}"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  QrImageView(
                    data: activeSession.qrData,
                    size: 250,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await qrProvider.endQRSession();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("QR Session ended")),
                      );
                    },
                    icon: Icon(Icons.stop),
                    label: Text("End Session"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else ...[
                  if (subjects.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No subjects available",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add subjects first to generate QR codes",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Go to Subjects"),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      "Select Subject",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSubjectId,
                      decoration: InputDecoration(
                        labelText: "Subject",
                        border: OutlineInputBorder(),
                      ),
                      items: subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubjectId = value;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _selectedSubjectId == null
                          ? null
                          : () async {
                              final success = await qrProvider.createQRSession(_selectedSubjectId!);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("QR Session created")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(qrProvider.error ?? "Failed to create session"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: Icon(Icons.qr_code),
                      label: Text("Generate QR Code"),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
