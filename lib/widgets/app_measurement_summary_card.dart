import 'package:material_ui/material_ui.dart';
import 'package:saludap/utils/app_sizes.dart';
import 'package:saludap/widgets/app_title.dart';

class AppMeasurementSummaryCard extends StatelessWidget {
  const AppMeasurementSummaryCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    required this.onPressed,
    this.summary,
    super.key,
  });

  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final String? summary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSizes.spacingSm),
                  Expanded(child: AppTitle(title, size: AppTitleSize.small)),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppSizes.spacingMd),
              AppTitle(value),
              const SizedBox(height: AppSizes.spacingXs),
              Text(subtitle),
              if (summary != null) ...[
                const Divider(height: AppSizes.spacingLg),
                Text(summary!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
