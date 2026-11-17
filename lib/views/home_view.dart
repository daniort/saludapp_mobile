import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saludap/view_models/blood_pressure_view_model.dart';
import 'package:saludap/view_models/glucose_view_model.dart';
import 'package:saludap/view_models/profiles_view_model.dart';
import 'package:saludap/view_models/session_view_model.dart';
import 'package:saludap/views/blood_pressure_form_view.dart';
import 'package:saludap/views/blood_pressure_readings_view.dart';
import 'package:saludap/views/dashboard_view.dart';
import 'package:saludap/views/glucose_form_view.dart';
import 'package:saludap/views/glucose_readings_view.dart';
import 'package:saludap/widgets/app_floating_action_button.dart';
import 'package:saludap/widgets/app_icon_button.dart';
import 'package:saludap/widgets/app_navigation_bar.dart';
import 'package:saludap/widgets/app_title.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static const _navigationItems = [
    AppNavigationItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppNavigationItem(
      label: 'Glucosa',
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop,
    ),
    AppNavigationItem(
      label: 'Presión',
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final profilesViewModel = context.read<ProfilesViewModel>();
    await profilesViewModel.load();
    if (!mounted) return;

    final profileId = profilesViewModel.selectedProfile?.id;
    if (profileId == null) return;
    await Future.wait([
      context.read<BloodPressureViewModel>().load(profileId),
      context.read<GlucoseViewModel>().load(profileId),
    ]);
  }

  Future<void> _openBloodPressureForm() async {
    final profile = context.read<ProfilesViewModel>().selectedProfile;
    if (profile == null) {
      _showMissingProfile();
      return;
    }
    final viewModel = context.read<BloodPressureViewModel>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: viewModel),
          ChangeNotifierProvider.value(
            value: context.read<ProfilesViewModel>(),
          ),
        ],
        child: const BloodPressureFormView(),
      ),
    );
  }

  Future<void> _openGlucoseForm() async {
    final profile = context.read<ProfilesViewModel>().selectedProfile;
    if (profile == null) {
      _showMissingProfile();
      return;
    }
    final viewModel = context.read<GlucoseViewModel>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: viewModel),
          ChangeNotifierProvider.value(
            value: context.read<ProfilesViewModel>(),
          ),
        ],
        child: const GlucoseFormView(),
      ),
    );
  }

  void _showMissingProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Primero necesitas crear un perfil personal.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: AppTitle(switch (_selectedIndex) {
          0 => 'Inicio',
          1 => 'Glucosa',
          _ => 'Presión arterial',
        }, size: AppTitleSize.small),
        actions: [
          AppIconButton(
            onPressed: session.isLoading ? null : session.logout,
            icon: Icons.logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardView(
            onOpenGlucose: () => setState(() => _selectedIndex = 1),
            onOpenBloodPressure: () => setState(() => _selectedIndex = 2),
          ),
          const GlucoseReadingsView(),
          const BloodPressureReadingsView(),
        ],
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        items: _navigationItems,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      floatingActionButton: switch (_selectedIndex) {
        1 => AppFloatingActionButton(
          heroTag: 'new_glucose',
          label: 'Nueva glucosa',
          icon: Icons.add,
          onPressed: _openGlucoseForm,
        ),
        2 => AppFloatingActionButton(
          heroTag: 'new_blood_pressure',
          label: 'Nueva presión',
          icon: Icons.add,
          onPressed: _openBloodPressureForm,
        ),
        _ => null,
      },
    );
  }
}
