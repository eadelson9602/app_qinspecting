import 'package:flutter/material.dart';

class LoadingProgressProvider extends ChangeNotifier {
  double _progress = 0.0;
  String _message = 'Cargando...';
  bool _isLoading = false;

  double get progress => _progress;
  String get message => _message;
  bool get isLoading => _isLoading;

  void startLoading({String message = 'Cargando...'}) {
    _isLoading = true;
    _progress = 0.0;
    _message = message;
    notifyListeners();
  }

  void updateProgress(double progress, {String? message}) {
    _progress = progress.clamp(0.0, 1.0);
    if (message != null) {
      _message = message;
    }
    notifyListeners();
  }

  void finishLoading() {
    _isLoading = false;
    _progress = 1.0;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    _progress = 0.0;
    notifyListeners();
  }
}
