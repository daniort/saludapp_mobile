import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saludap/widgets/app_floating_action_button.dart';

void main() {
  testWidgets('executes the supplied callback', (tester) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: AppFloatingActionButton(
            heroTag: 'test_action',
            label: 'Nueva lectura',
            icon: Icons.add,
            onPressed: () => wasPressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Nueva lectura'));

    expect(wasPressed, isTrue);
  });
}
