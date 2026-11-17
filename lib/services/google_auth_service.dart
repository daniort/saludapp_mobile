import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saludap/utils/app_config.dart';

abstract interface class GoogleAuthService {
  Future<String> authenticate();
  Future<void> signOut();
}

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message, {this.wasCanceled = false});

  final String message;
  final bool wasCanceled;

  @override
  String toString() => message;
}

class GoogleAuthServiceImpl implements GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _initialization;

  @override
  Future<String> authenticate() async {
    await (_initialization ??= _initialize());
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthException(
        'Google no está disponible en esta plataforma.',
      );
    }

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google no devolvió un token de identidad.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const GoogleAuthException(
          'Inicio de sesión cancelado.',
          wasCanceled: true,
        );
      }
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw const GoogleAuthException(
          'Google Sign-In todavía no está configurado para esta aplicación.',
        );
      }
      throw const GoogleAuthException(
        'No fue posible iniciar sesión con Google.',
      );
    }
  }

  Future<void> _initialize() {
    if (AppConfig.googleServerClientId.isEmpty) {
      throw const GoogleAuthException(
        'Falta configurar GOOGLE_SERVER_CLIENT_ID.',
      );
    }

    final usesIosClientId =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    if (usesIosClientId && AppConfig.googleIosClientId.isEmpty) {
      throw const GoogleAuthException('Falta configurar GOOGLE_IOS_CLIENT_ID.');
    }

    return _googleSignIn.initialize(
      clientId: usesIosClientId ? AppConfig.googleIosClientId : null,
      serverClientId: AppConfig.googleServerClientId,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await (_initialization ??= _initialize());
      await _googleSignIn.signOut();
    } catch (_) {
      // El cierre de la sesión local no depende del SDK de Google.
    }
  }
}
