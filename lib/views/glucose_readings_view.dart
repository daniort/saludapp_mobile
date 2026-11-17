import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/models/glucose_reading_model.dart';
import 'package:saludap/models/profile_model.dart';
import 'package:saludap/utils/app_date_formatter.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/blood_pressure_view_model.dart';
import 'package:saludap/view_models/glucose_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/widgets/app_empty_state.dart';
import 'package:saludap/widgets/app_profile_selector.dart';
import 'package:saludap/widgets/app_title.dart';

class GlucoseReadingsView extends StatelessWidget {
  const GlucoseReadingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfilesViewModel>();
    final glucose = context.watch<GlucoseViewModel>();

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

    final readings = glucose.readings;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      child: Column(
        children: [
          AppProfileSelector(
            profiles: profiles.profiles,
            selectedProfile: profiles.selectedProfile!,
            onChanged: (profile) => _selectProfile(context, profile),
          ),
          if (glucose.isLoading) const LinearProgressIndicator(),
          const SizedBox(height: AppSizes.spacingMd),
          Expanded(
            child: glucose.errorMessage != null && readings.isEmpty
                ? AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'No pudimos cargar las lecturas',
                    message: glucose.errorMessage!,
                    actionLabel: 'Reintentar',
                    onAction: glucose.refresh,
                  )
                : readings.isEmpty
                ? const AppEmptyState(
                    icon: Icons.water_drop_outlined,
                    title: 'Sin lecturas de glucosa',
                    message: 'Usa el botón inferior para agregar la primera.',
                  )
                : RefreshIndicator(
                    onRefresh: glucose.refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: readings.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSizes.spacingSm),
                      itemBuilder: (context, index) =>
                          GlucoseReadingCard(reading: readings[index]),
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

class GlucoseReadingCard extends StatelessWidget {
  const GlucoseReadingCard({required this.reading, super.key});

  final GlucoseReadingModel reading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTitle(
              '${reading.value.toStringAsFixed(reading.value % 1 == 0 ? 0 : 2)} ${reading.unit}',
              size: AppTitleSize.small,
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Text(AppDateFormatter.dateTime(reading.takenAt)),
            Text(reading.takenContext.label),
            if (reading.notes != null && reading.notes!.isNotEmpty)
              Text(reading.notes!),
          ],
        ),
      ),
    );
  }
}
