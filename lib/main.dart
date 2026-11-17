import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/app.dart';
import 'package:saludap/repositories/auth_repository.dart';
import 'package:saludap/repositories/blood_pressure_repository.dart';
import 'package:saludap/repositories/glucose_repository.dart';
import 'package:saludap/repositories/profile_repository.dart';
import 'package:saludap/services/api_client.dart';
import 'package:saludap/services/google_auth_service.dart';
import 'package:saludap/services/session_storage.dart';
import 'package:saludap/view_models/session_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          dispose: (_, apiClient) => apiClient.close(),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(context.read<ApiClient>()),
        ),
        Provider<GoogleAuthService>(create: (_) => GoogleAuthServiceImpl()),
        Provider<SessionStorage>(create: (_) => SecureSessionStorage()),
        Provider<ProfileRepository>(
          create: (context) => ProfileRepository(context.read<ApiClient>()),
        ),
        Provider<BloodPressureRepository>(
          create: (context) =>
              BloodPressureRepository(context.read<ApiClient>()),
        ),
        Provider<GlucoseRepository>(
          create: (context) => GlucoseRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<SessionViewModel>(
          create: (context) => SessionViewModel(
            context.read<AuthRepository>(),
            context.read<SessionStorage>(),
            context.read<GoogleAuthService>(),
          )..initialize(),
        ),
      ],
      child: const SaludapApp(),
    ),
  );
}
