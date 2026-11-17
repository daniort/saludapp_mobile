import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/app.dart';
import 'package:saludap/models/auth_model.dart';
import 'package:saludap/repositories/auth_repository.dart';
import 'package:saludap/services/api_client.dart';
import 'package:saludap/services/google_auth_service.dart';
import 'package:saludap/services/session_storage.dart';
import 'package:saludap/utils/app_constants.dart';
import 'package:saludap/view_models/session_view_model.dart';

void main() {
  testWidgets('shows the login form with development credentials', (
    tester,
  ) async {
    final apiClient = ApiClient(dio: Dio());
    addTearDown(apiClient.close);
    final session = SessionViewModel(
      AuthRepository(apiClient),
      _MemorySessionStorage(),
      _FakeGoogleAuthService(),
    );
    await session.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: apiClient),
          Provider(create: (_) => AuthRepository(apiClient)),
          ChangeNotifierProvider.value(value: session),
        ],
        child: const SaludapApp(),
      ),
    );

    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));

    expect(fields, hasLength(2));
    expect(fields.first.controller?.text, AppConstants.testEmail);
    expect(fields.last.controller?.text, AppConstants.testPassword);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });
}

class _FakeGoogleAuthService implements GoogleAuthService {
  @override
  Future<String> authenticate() async => 'google-id-token';

  @override
  Future<void> signOut() async {}
}

class _MemorySessionStorage implements SessionStorage {
  StoredSession? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<StoredSession?> read() async => value;

  @override
  Future<void> write(AuthModel auth) async {
    value = StoredSession(
      auth: auth,
      expiresAt: DateTime.now().add(Duration(seconds: auth.tokens.expiresIn)),
    );
  }
}
