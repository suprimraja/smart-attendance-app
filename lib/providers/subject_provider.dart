import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';
import '../services/storage_service.dart';

class SubjectProvider with ChangeNotifier {
  List<SubjectModel> _subjects = [];
  bool _isLoading = false;
  String? _error;

  List<SubjectModel> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SubjectProvider() {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subjects = StorageService.getAllSubjects();
      _subjects.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject(SubjectModel subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.saveSubject(subject);
      await loadSubjects();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(SubjectModel subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.saveSubject(subject);
      await loadSubjects();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteSubject(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.deleteSubject(id);
      await loadSubjects();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  SubjectModel? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}

