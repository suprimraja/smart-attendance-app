import 'package:uuid/uuid.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/qr_session_model.dart';
import 'storage_service.dart';

class AttendanceService {
  static const _uuid = Uuid();

  // Check if student already marked attendance for this session
  static bool hasStudentMarkedAttendance(String studentId, String qrData) {
    final allAttendance = StorageService.getAllAttendance();
    return allAttendance.any((attendance) =>
        attendance.studentId == studentId &&
        attendance.qrCodeData == qrData);
  }

  // Mark attendance
  static Future<AttendanceModel> markAttendance({
    required String studentId,
    required String qrData,
  }) async {
    // Parse QR data (format: subjectId|timestamp)
    final parts = qrData.split('|');
    if (parts.length < 2) {
      throw Exception('Invalid QR code format');
    }

    final subjectId = parts[0];
    final subject = StorageService.getSubjectById(subjectId);
    if (subject == null) {
      throw Exception('Subject not found');
    }

    final student = StorageService.getStudentById(studentId);
    if (student == null) {
      throw Exception('Student not found');
    }

    // Check for duplicates
    if (hasStudentMarkedAttendance(studentId, qrData)) {
      throw Exception('Attendance already marked for this session');
    }

    final attendance = AttendanceModel(
      id: _uuid.v4(),
      studentId: studentId,
      studentName: student.name,
      rollNumber: student.rollNumber,
      subjectId: subjectId,
      subjectName: subject.name,
      timestamp: DateTime.now(),
      qrCodeData: qrData,
    );

    await StorageService.saveAttendance(attendance);
    return attendance;
  }

  // Get attendance statistics
  static Map<String, dynamic> getAttendanceStats() {
    final allAttendance = StorageService.getAllAttendance();
    final allStudents = StorageService.getAllStudents();
    final allSubjects = StorageService.getAllSubjects();

    final totalAttendance = allAttendance.length;
    final totalStudents = allStudents.length;
    final totalSubjects = allSubjects.length;

    // Attendance by subject
    final attendanceBySubject = <String, int>{};
    for (var attendance in allAttendance) {
      attendanceBySubject[attendance.subjectName] =
          (attendanceBySubject[attendance.subjectName] ?? 0) + 1;
    }

    // Attendance by student
    final attendanceByStudent = <String, int>{};
    for (var attendance in allAttendance) {
      attendanceByStudent[attendance.studentId] =
          (attendanceByStudent[attendance.studentId] ?? 0) + 1;
    }

    // Today's attendance
    final today = DateTime.now();
    final todayAttendance = allAttendance.where((a) {
      return a.timestamp.year == today.year &&
          a.timestamp.month == today.month &&
          a.timestamp.day == today.day;
    }).length;

    return {
      'totalAttendance': totalAttendance,
      'totalStudents': totalStudents,
      'totalSubjects': totalSubjects,
      'todayAttendance': todayAttendance,
      'attendanceBySubject': attendanceBySubject,
      'attendanceByStudent': attendanceByStudent,
    };
  }
}

