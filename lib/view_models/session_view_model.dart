import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:saludap/models/auth_model.dart';
import 'package:saludap/repositories/auth_repository.dart';
import 'package:saludap/services/api_exception.dart';
import 'package:saludap/services/google_auth_service.dart';
import 'package:saludap/services/session_storage.dart';

enum SessionStatus { initializing, unauthenticated, loading, authenticated }

class SessionViewModel extends ChangeNotifier {
  SessionViewModel(
    this._authRepository,
    this._sessionStorage,
    this._googleAuthService,
  );

  final AuthRepository _authRepository;
  final SessionStorage _sessionStorage;
  final GoogleAuthService _googleAuthService;

  SessionStatus _status = SessionStatus.initializing;
  AuthModel? _auth;
  String? _errorMessage;
  Timer? _refreshTimer;

  SessionStatus get status => _status;
  AuthModel? get auth => _auth;
  String? get errorMessage => _errorMessage;
  bool get isInitializing => _status == SessionStatus.initializing;
  bool get isLoading => _status == SessionStatus.loading;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  Future<void> initialize() async {
    try {
      final storedSession = await _sessionStorage.read();
      if (storedSession == null) {
        _status = SessionStatus.unauthenticated;
      } else if (storedSession.needsRefresh) {
        final tokens = await _authRepository.refresh(
          storedSession.auth.tokens.refreshToken,
        );
        await _establishSession(storedSession.auth.withTokens(tokens));
      } else {
        _auth = storedSession.auth;
        _authRepository.activateSession(storedSession.auth);
        _status = SessionStatus.authenticated;
        _scheduleRefresh(storedSession.expiresAt.difference(DateTime.now()));
      }
    } catch (_) {
      await _clearLocalSession();
      _status = SessionStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _runAuthentication(
      () => _authRepository.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String givenNames,
    String? paternalSurname,
    String? maternalSurname,
    DateTime? birthDate,
  }) async {
    return _runAuthentication(
      () => _authRepository.register(
        email: email,
        password: password,
        givenNames: givenNames,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
        birthDate: birthDate,
      ),
    );
  }

  Future<bool> loginWithGoogle() async {
    if (_status == SessionStatus.loading) return false;
    _status = SessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final googleIdToken = await _googleAuthService.authenticate();
      await _establishSession(
        await _authRepository.loginWithGoogle(googleIdToken),
      );
      notifyListeners();
      return true;
    } on GoogleAuthException catch (error) {
      if (!error.wasCanceled) _errorMessage = error.message;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      await _googleAuthService.signOut();
    } catch (_) {
      _errorMessage = 'No fue posible iniciar sesión con Google.';
      await _googleAuthService.signOut();
    }

    _status = SessionStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    if (_status == SessionStatus.loading) return;
    _status = SessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (_) {
      // El cierre local debe ocurrir aunque el backend no esté disponible.
    } finally {
      _refreshTimer?.cancel();
      await _googleAuthService.signOut();
      await _clearLocalSession();
      _auth = null;
      _status = SessionStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> _runAuthentication(Future<AuthModel> Function() action) async {
    if (_status == SessionStatus.loading) return false;
    _status = SessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _establishSession(await action());
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado.';
    }

    _status = SessionStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> _establishSession(AuthModel auth) async {
    _authRepository.activateSession(auth);
    await _sessionStorage.write(auth);
    _auth = auth;
    _status = SessionStatus.authenticated;
    _scheduleRefresh(Duration(seconds: auth.tokens.expiresIn));
  }

  void _scheduleRefresh(Duration lifetime) {
    _refreshTimer?.cancel();
    final delay = lifetime > const Duration(minutes: 1)
        ? lifetime - const Duration(minutes: 1)
        : const Duration(seconds: 1);
    _refreshTimer = Timer(delay, _refreshCurrentSession);
  }

  Future<void> _refreshCurrentSession() async {
    final currentAuth = _auth;
    if (currentAuth == null) return;

    try {
      final tokens = await _authRepository.refresh(
        currentAuth.tokens.refreshToken,
      );
      await _establishSession(currentAuth.withTokens(tokens));
      notifyListeners();
    } catch (_) {
      await _clearLocalSession();
      _auth = null;
      _status = SessionStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _clearLocalSession() async {
    _authRepository.clearSession();
    try {
      await _sessionStorage.clear();
    } catch (_) {
      // La sesión en memoria se elimina aunque el almacén del sistema falle.
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
