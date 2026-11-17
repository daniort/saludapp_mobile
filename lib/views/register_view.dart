import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/session_view_model.dart';
import 'package:saludap/widgets/app_primary_button.dart';
import 'package:saludap/widgets/app_text_field.dart';
import 'package:saludap/widgets/app_title.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _givenNamesController = TextEditingController();
  final _paternalSurnameController = TextEditingController();
  final _maternalSurnameController = TextEditingController();
  final _birthDateController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _givenNamesController.dispose();
    _paternalSurnameController.dispose();
    _maternalSurnameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate == null) return;

    setState(() {
      _birthDate = selectedDate;
      _birthDateController.text = _formatDate(selectedDate);
    });
  }

  Future<void> _register() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final registered = await context.read<SessionViewModel>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      givenNames: _givenNamesController.text.trim(),
      paternalSurname: _nullableText(_paternalSurnameController.text),
      maternalSurname: _nullableText(_maternalSurnameController.text),
      birthDate: _birthDate,
    );

    if (registered && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const AppTitle('Crear cuenta', size: AppTitleSize.small),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppTitle('Tus datos'),
                const SizedBox(height: AppSizes.spacingLg),
                AppTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa una contraseña.'
                      : null,
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppTextField(
                  controller: _givenNamesController,
                  label: 'Nombre(s)',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa tu nombre.'
                      : null,
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppTextField(
                  controller: _paternalSurnameController,
                  label: 'Apellido paterno (opcional)',
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppTextField(
                  controller: _maternalSurnameController,
                  label: 'Apellido materno (opcional)',
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppTextField(
                  controller: _birthDateController,
                  label: 'Fecha de nacimiento (opcional)',
                  prefixIcon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: _selectBirthDate,
                ),
                if (session.errorMessage != null) ...[
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    session.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingLg),
                AppPrimaryButton(
                  label: 'Crear cuenta',
                  icon: Icons.person_add_outlined,
                  isLoading: session.isLoading,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  String? _nullableText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
