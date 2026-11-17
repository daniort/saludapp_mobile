import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/models/blood_pressure_reading_model.dart';
import 'package:saludap/models/profile_model.dart';
import 'package:saludap/utils/app_date_formatter.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/blood_pressure_view_model.dart';
import 'package:saludap/view_models/glucose_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/widgets/app_empty_state.dart';
import 'package:saludap/widgets/app_profile_selector.dart';
import 'package:saludap/widgets/app_title.dart';

class BloodPressureReadingsView extends StatelessWidget {
  const BloodPressureReadingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfilesViewModel>();
    final pressure = context.watch<BloodPressureViewModel>();

    if (profiles.isLoading && !profiles.hasProfiles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profiles.errorMessage != null && !profiles.hasProfiles) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'No pudimos cargar los perfiles',
        message: profiles.errorMessage!,
        actionLabel: 'Reintentar',
        onAction: profiles.load,
      );
    }
    if (!profiles.hasProfiles) {
      return const AppEmptyState(
        icon: Icons.person_add_alt_1_outlined,
        title: 'Aún no tienes perfiles',
        message: 'El registro debe crear tu perfil personal automáticamente.',
      );
    }

    final readings = pressure.readings;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      child: Column(
        children: [
          AppProfileSelector(
            profiles: profiles.profiles,
            selectedProfile: profiles.selectedProfile!,
            onChanged: (profile) => _selectProfile(context, profile),
          ),
          if (pressure.isLoading) const LinearProgressIndicator(),
          const SizedBox(height: AppSizes.spacingMd),
          Expanded(
            child: pressure.errorMessage != null && readings.isEmpty
                ? AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'No pudimos cargar las lecturas',
                    message: pressure.errorMessage!,
                    actionLabel: 'Reintentar',
                    onAction: pressure.refresh,
                  )
                : readings.isEmpty
                ? const AppEmptyState(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Sin lecturas de presión',
                    message: 'Usa el botón inferior para agregar la primera.',
                  )
                : RefreshIndicator(
                    onRefresh: pressure.refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: readings.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSizes.spacingSm),
                      itemBuilder: (context, index) =>
                          BloodPressureReadingCard(reading: readings[index]),
                    ),
                  ),
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
}

class BloodPressureReadingCard extends StatelessWidget {
  const BloodPressureReadingCard({required this.reading, super.key});

  final BloodPressureReadingModel reading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTitle(
              '${reading.systolic}/${reading.diastolic} mmHg',
              size: AppTitleSize.small,
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Text(AppDateFormatter.dateTime(reading.takenAt)),
            if (reading.pulse != null) Text('Pulso: ${reading.pulse} lpm'),
            if (reading.notes != null && reading.notes!.isNotEmpty)
              Text(reading.notes!),
          ],
        ),
      ),
    );
  }
}
