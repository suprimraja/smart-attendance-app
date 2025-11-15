import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../services/storage_service.dart';
import '../services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceModel> _attendanceList = [];
  bool _isLoading = false;
  String? _error;

  List<AttendanceModel> get attendanceList => _attendanceList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic> get stats => AttendanceService.getAttendanceStats();

  AttendanceProvider() {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceList = StorageService.getAllAttendance();
      _attendanceList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance(String studentId, String qrData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AttendanceService.markAttendance(
        studentId: studentId,
        qrData: qrData,
      );
      await loadAttendance();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAttendance(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.deleteAttendance(id);
      await loadAttendance();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<AttendanceModel> getAttendanceBySubject(String subjectId) {
    return _attendanceList.where((a) => a.subjectId == subjectId).toList();
  }

  List<AttendanceModel> getAttendanceByStudent(String studentId) {
    return _attendanceList.where((a) => a.studentId == studentId).toList();
  }
}

