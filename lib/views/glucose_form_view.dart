import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/models/glucose_reading_model.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/glucose_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/widgets/app_dropdown_field.dart';
import 'package:saludap/widgets/app_primary_button.dart';
import 'package:saludap/widgets/app_text_field.dart';
import 'package:saludap/widgets/app_title.dart';

class GlucoseFormView extends StatefulWidget {
  const GlucoseFormView({super.key});

  @override
  State<GlucoseFormView> createState() => _GlucoseFormViewState();
}

class _GlucoseFormViewState extends State<GlucoseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  GlucoseTakenContext _takenContext = GlucoseTakenContext.fasting;

  static final _contexts = GlucoseTakenContext.selectableValues
      .map((context) => AppDropdownItem(value: context, label: context.label))
      .toList(growable: false);

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profileId = context.read<ProfilesViewModel>().selectedProfile!.id;
    final saved = await context.read<GlucoseViewModel>().create(
      profileId: profileId,
      value: double.parse(_valueController.text),
      takenContext: _takenContext,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GlucoseViewModel>();

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
              const AppTitle('Nueva lectura de glucosa'),
              const SizedBox(height: AppSizes.spacingLg),
              AppTextField(
                controller: _valueController,
                label: 'Glucosa (mg/dL)',
                prefixIcon: Icons.water_drop_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  return parsed == null || parsed <= 0
                      ? 'Ingresa un número positivo.'
                      : null;
                },
              ),
              const SizedBox(height: AppSizes.spacingMd),
              AppDropdownField<GlucoseTakenContext>(
                label: 'Momento de la medición',
                prefixIcon: Icons.schedule,
                initialValue: _takenContext,
                items: _contexts,
                onChanged: (value) {
                  if (value != null) setState(() => _takenContext = value);
                },
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
}
