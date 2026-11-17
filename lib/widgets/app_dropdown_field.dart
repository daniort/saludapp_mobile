import 'package:material_ui/material_ui.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.prefixIcon,
    super.key,
  });

  final String label;
  final List<AppDropdownItem<T>> items;
  final T? initialValue;
  final IconData? prefixIcon;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item.value, child: Text(item.label)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
