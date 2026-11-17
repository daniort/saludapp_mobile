import 'package:material_ui/material_ui.dart';

enum ViewStatus { initial, loading, success, error }

/// Shared state that feature-specific view models can extend when useful.
abstract class BaseViewModel extends ChangeNotifier {
  ViewStatus _status = ViewStatus.initial;
  Object? _error;

  ViewStatus get status => _status;
  Object? get error => _error;
  bool get isLoading => _status == ViewStatus.loading;

  @protected
  void setStatus(ViewStatus value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }

  @protected
  void setError(Object error) {
    _error = error;
    setStatus(ViewStatus.error);
  }

  @protected
  void clearError() {
    _error = null;
  }
}
