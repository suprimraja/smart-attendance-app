import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/qr_session_model.dart';
import '../models/subject_model.dart';
import 'storage_service.dart';

class QRService {
  static const _uuid = Uuid();

  // Generate QR data for a subject
  static String generateQRData(String subjectId) {
    final timestamp = DateTime.now().toIso8601String();
    return '$subjectId|$timestamp';
  }

  // Create a new QR session
  static Future<QRSessionModel> createQRSession(String subjectId) async {
    // Deactivate all existing sessions
    await StorageService.deactivateAllSessions();

    final subject = StorageService.getSubjectById(subjectId);
    if (subject == null) {
      throw Exception('Subject not found');
    }

    final qrData = generateQRData(subjectId);
    final session = QRSessionModel(
      id: _uuid.v4(),
      subjectId: subjectId,
      subjectName: subject.name,
      startTime: DateTime.now(),
      qrData: qrData,
      isActive: true,
    );

    await StorageService.saveQRSession(session);
    return session;
  }

  // End current QR session
  static Future<void> endQRSession(String sessionId) async {
    final sessions = StorageService.getAllQRSessions();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
    session.isActive = false;
    session.endTime = DateTime.now();
    await StorageService.saveQRSession(session);
  }

  // Get active QR session
  static QRSessionModel? getActiveSession() {
    return StorageService.getActiveQRSession();
  }
}

