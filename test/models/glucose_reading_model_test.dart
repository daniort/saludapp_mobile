import 'package:flutter_test/flutter_test.dart';
import 'package:saludap/models/glucose_reading_model.dart';

void main() {
  test('exposes only the four supported contexts for new readings', () {
    expect(
      GlucoseTakenContext.selectableValues.map((value) => value.apiValue),
      ['fasting', 'before_meal', 'after_meal', 'bedtime'],
    );
  });

  test('keeps compatibility with legacy context values', () {
    final reading = GlucoseReadingModel.fromJson({
      'id': 'reading-id',
      'profileId': 'profile-id',
      'value': 95,
      'unit': 'mg/dL',
      'takenContext': 'random',
      'notes': null,
      'takenAt': '2026-11-14T12:00:00.000Z',
    });

    expect(reading.takenContext, GlucoseTakenContext.random);
    expect(reading.takenContext.isSelectable, isFalse);
  });
}
