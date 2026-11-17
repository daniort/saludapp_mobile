import 'package:material_ui/material_ui.dart';

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
