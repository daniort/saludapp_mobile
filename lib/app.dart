import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/repositories/blood_pressure_repository.dart';
import 'package:saludap/repositories/glucose_repository.dart';
import 'package:saludap/repositories/profile_repository.dart';
import 'package:saludap/utils/app_constants.dart';
import 'package:saludap/utils/app_theme.dart';
import 'package:saludap/view_models/blood_pressure_view_model.dart';
import 'package:saludap/view_models/glucose_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/view_models/session_view_model.dart';
import 'package:saludap/views/home_view.dart';
import 'package:saludap/views/login_view.dart';

class SaludapApp extends StatelessWidget {
  const SaludapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Consumer<SessionViewModel>(
        builder: (context, session, child) {
          if (session.isInitializing) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!session.isAuthenticated) return const LoginView();

          return MultiProvider(
            key: ValueKey(session.auth!.user.uid),
            providers: [
              ChangeNotifierProvider(
                create: (context) =>
                    ProfilesViewModel(context.read<ProfileRepository>()),
              ),
              ChangeNotifierProvider(
                create: (context) => BloodPressureViewModel(
                  context.read<BloodPressureRepository>(),
                ),
              ),
              ChangeNotifierProvider(
                create: (context) =>
                    GlucoseViewModel(context.read<GlucoseRepository>()),
              ),
            ],
            child: const HomeView(),
          );
        },
      ),
    );
  }
}
