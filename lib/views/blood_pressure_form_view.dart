import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/blood_pressure_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/widgets/app_primary_button.dart';
import 'package:saludap/widgets/app_text_field.dart';
import 'package:saludap/widgets/app_title.dart';

class BloodPressureFormView extends StatefulWidget {
  const BloodPressureFormView({super.key});

  @override
  State<BloodPressureFormView> createState() => _BloodPressureFormViewState();
}

class _BloodPressureFormViewState extends State<BloodPressureFormView> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profileId = context.read<ProfilesViewModel>().selectedProfile!.id;
    final saved = await context.read<BloodPressureViewModel>().create(
      profileId: profileId,
      systolic: int.parse(_systolicController.text),
      diastolic: int.parse(_diastolicController.text),
      pulse: _pulseController.text.isEmpty
          ? null
          : int.parse(_pulseController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BloodPressureViewModel>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSizes.spacingLg,
          AppSizes.spacingLg,
          AppSizes.spacingLg,
          MediaQuery.viewInsetsOf(context).bottom + AppSizes.spacingLg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTitle('Nueva lectura de presión'),
              const SizedBox(height: AppSizes.spacingLg),
              AppTextField(
                controller: _systolicController,
                label: 'Sistólica (mmHg)',
                prefixIcon: Icons.arrow_upward,
                keyboardType: TextInputType.number,
                validator: _requiredPositiveInteger,
              ),
              const SizedBox(height: AppSizes.spacingMd),
              AppTextField(
                controller: _diastolicController,
                label: 'Diastólica (mmHg)',
                prefixIcon: Icons.arrow_downward,
                keyboardType: TextInputType.number,
                validator: _requiredPositiveInteger,
              ),
              const SizedBox(height: AppSizes.spacingMd),
              AppTextField(
                controller: _pulseController,
                label: 'Pulso (opcional)',
                prefixIcon: Icons.favorite_outline,
                keyboardType: TextInputType.number,
                validator: _optionalPositiveInteger,
              ),
              const SizedBox(height: AppSizes.spacingMd),
              AppTextField(
                controller: _notesController,
                label: 'Notas (opcional)',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: AppSizes.spacingMd),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSizes.spacingLg),
              AppPrimaryButton(
                label: 'Guardar lectura',
                icon: Icons.save_outlined,
                isLoading: viewModel.isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredPositiveInteger(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed == null || parsed <= 0 ? 'Ingresa un número positivo.' : null;
  }

  String? _optionalPositiveInteger(String? value) {
    if (value == null || value.isEmpty) return null;
    return _requiredPositiveInteger(value);
  }
}
