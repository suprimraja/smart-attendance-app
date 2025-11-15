import 'package:flutter/foundation.dart';
import '../models/qr_session_model.dart';
import '../services/qr_service.dart';

class QRProvider with ChangeNotifier {
  QRSessionModel? _activeSession;
  bool _isLoading = false;
  String? _error;

  QRSessionModel? get activeSession => _activeSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSession => _activeSession != null;

  QRProvider() {
    loadActiveSession();
  }

  Future<void> loadActiveSession() async {
    _activeSession = QRService.getActiveSession();
    notifyListeners();
  }

  Future<bool> createQRSession(String subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeSession = await QRService.createQRSession(subjectId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> endQRSession() async {
    if (_activeSession == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await QRService.endQRSession(_activeSession!.id);
      _activeSession = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

