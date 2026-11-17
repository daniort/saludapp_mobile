import 'package:material_ui/material_ui.dart';

enum AppTitleSize { large, medium, small }

class AppTitle extends StatelessWidget {
  const AppTitle(
    this.text, {
    this.size = AppTitleSize.medium,
    this.textAlign,
    super.key,
  });

  final String text;
  final AppTitleSize size;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = switch (size) {
      AppTitleSize.large => textTheme.headlineLarge,
      AppTitleSize.medium => textTheme.headlineMedium,
      AppTitleSize.small => textTheme.titleLarge,
    };

    return Text(text, style: style, textAlign: textAlign);
  }
}
