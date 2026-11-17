import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/utils/app_constants.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/view_models/session_view_model.dart';
import 'package:saludap/views/register_view.dart';
import 'package:saludap/widgets/app_primary_button.dart';
import 'package:saludap/widgets/app_secondary_button.dart';
import 'package:saludap/widgets/app_text_field.dart';
import 'package:saludap/widgets/app_title.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: AppConstants.testEmail);
    _passwordController = TextEditingController(
      text: AppConstants.testPassword,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await context.read<SessionViewModel>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppTitle(
                        AppConstants.appName,
                        size: AppTitleSize.large,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.spacingSm),
                      Text(
                        'Inicia sesión para continuar',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.spacingXl),
                      AppTextField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        prefixIcon: Icons.email_outlined,
                        enabled: !session.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Ingresa tu correo.';
                          if (!email.contains('@')) {
                            return 'Ingresa un correo válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacingMd),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        prefixIcon: Icons.lock_outline,
                        enabled: !session.isLoading,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña.';
                          }
                          return null;
                        },
                      ),
                      if (session.errorMessage != null) ...[
                        const SizedBox(height: AppSizes.spacingMd),
                        Text(
                          session.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSizes.spacingLg),
                      AppPrimaryButton(
                        label: 'Iniciar sesión',
                        onPressed: session.isLoading ? null : _submit,
                        isLoading: session.isLoading,
                      ),
                      const SizedBox(height: AppSizes.spacingMd),
                      AppSecondaryButton(
                        label: 'Continuar con Google',
                        icon: Icons.account_circle_outlined,
                        onPressed: session.isLoading
                            ? null
                            : session.loginWithGoogle,
                      ),
                      const SizedBox(height: AppSizes.spacingMd),
                      AppSecondaryButton(
                        label: 'Crear una cuenta',
                        icon: Icons.person_add_outlined,
                        onPressed: session.isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterView(),
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
