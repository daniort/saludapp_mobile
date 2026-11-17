import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/models/profile_model.dart';
import 'package:saludap/utils/app_date_formatter.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/blood_pressure_view_model.dart';
import 'package:saludap/view_models/glucose_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/widgets/app_empty_state.dart';
import 'package:saludap/widgets/app_measurement_summary_card.dart';
import 'package:saludap/widgets/app_profile_selector.dart';
import 'package:saludap/widgets/app_title.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    required this.onOpenGlucose,
    required this.onOpenBloodPressure,
    super.key,
  });

  final VoidCallback onOpenGlucose;
  final VoidCallback onOpenBloodPressure;

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfilesViewModel>();
    final pressure = context.watch<BloodPressureViewModel>();
    final glucose = context.watch<GlucoseViewModel>();

    if (profiles.isLoading && !profiles.hasProfiles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!profiles.hasProfiles) {
      return const AppEmptyState(
        icon: Icons.person_outline,
        title: 'No encontramos tu perfil',
        message: 'Vuelve a iniciar sesión o intenta cargarlo nuevamente.',
      );
    }

    final profile = profiles.selectedProfile!;
    final latestPressure = pressure.latestReading;
    final pressureSummary = pressure.sevenDaySummary;
    final latestGlucose = glucose.latestReading;
    final glucoseSummary = glucose.sevenDaySummaryForLatestContext;

    return RefreshIndicator(
      onRefresh: () => Future.wait([pressure.refresh(), glucose.refresh()]),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        children: [
          AppTitle('Hola, ${profile.givenNames}'),
          const SizedBox(height: AppSizes.spacingSm),
          AppProfileSelector(
            profiles: profiles.profiles,
            selectedProfile: profile,
            onChanged: (value) => _selectProfile(context, value),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          const AppTitle('Últimas mediciones', size: AppTitleSize.small),
          const SizedBox(height: AppSizes.spacingSm),
          AppMeasurementSummaryCard(
            title: 'Glucosa',
            icon: Icons.water_drop_outlined,
            value: latestGlucose == null
                ? 'Sin registros'
                : '${_formatGlucose(latestGlucose.value)} ${latestGlucose.unit}',
            subtitle: latestGlucose == null
                ? 'Registra tu primera medición'
                : '${latestGlucose.takenContext.label} · ${AppDateFormatter.dateTime(latestGlucose.takenAt)}',
            summary: glucoseSummary == null
                ? null
                : 'Promedio de 7 días (${glucoseSummary.context.label.toLowerCase()}): '
                      '${_formatGlucose(glucoseSummary.average)} mg/dL · '
                      '${glucoseSummary.count} lecturas',
            onPressed: onOpenGlucose,
          ),
          const SizedBox(height: AppSizes.spacingSm),
          AppMeasurementSummaryCard(
            title: 'Presión arterial',
            icon: Icons.monitor_heart_outlined,
            value: latestPressure == null
                ? 'Sin registros'
                : '${latestPressure.systolic}/${latestPressure.diastolic} mmHg',
            subtitle: latestPressure == null
                ? 'Registra tu primera medición'
                : AppDateFormatter.dateTime(latestPressure.takenAt),
            summary: pressureSummary == null
                ? null
                : 'Promedio de 7 días: '
                      '${pressureSummary.averageSystolic.round()}/'
                      '${pressureSummary.averageDiastolic.round()} mmHg · '
                      '${pressureSummary.count} lecturas',
            onPressed: onOpenBloodPressure,
          ),
        ],
      ),
    );
  }

  Future<void> _selectProfile(
    BuildContext context,
    ProfileModel profile,
  ) async {
    context.read<ProfilesViewModel>().select(profile);
    await Future.wait([
      context.read<BloodPressureViewModel>().load(profile.id),
      context.read<GlucoseViewModel>().load(profile.id),
    ]);
  }

  String _formatGlucose(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  }
}
