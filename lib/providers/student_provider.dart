import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../services/storage_service.dart';

class StudentProvider with ChangeNotifier {
  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _error;

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StudentProvider() {
    loadStudents();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = StorageService.getAllStudents();
      _students.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent(StudentModel student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if roll number already exists
      final existing = _students.where((s) => s.rollNumber == student.rollNumber).toList();
      if (existing.isNotEmpty) {
        _error = 'Student with this roll number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await StorageService.saveStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(StudentModel student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.saveStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteStudent(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.deleteStudent(id);
      await loadStudents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  StudentModel? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  StudentModel? getStudentByRollNumber(String rollNumber) {
    try {
      return _students.firstWhere((s) => s.rollNumber == rollNumber);
    } catch (e) {
      return null;
    }
  }
}

