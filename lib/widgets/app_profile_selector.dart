import 'package:material_ui/material_ui.dart';
import 'package:saludap/models/profile_model.dart';
import 'package:saludap/widgets/app_dropdown_field.dart';

class AppProfileSelector extends StatelessWidget {
  const AppProfileSelector({
    required this.profiles,
    required this.selectedProfile,
    required this.onChanged,
    super.key,
  });

  final List<ProfileModel> profiles;
  final ProfileModel selectedProfile;
  final ValueChanged<ProfileModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDropdownField<ProfileModel>(
      key: ValueKey(selectedProfile.id),
      label: 'Perfil',
      prefixIcon: Icons.person_outline,
      initialValue: selectedProfile,
      items: profiles
          .map(
            (profile) =>
                AppDropdownItem(value: profile, label: profile.fullName),
          )
          .toList(),
      onChanged: (profile) {
        if (profile != null) onChanged(profile);
      },
    );
  }
}
